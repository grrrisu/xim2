defmodule Biotope.SimulationTest do
  use ExUnit.Case, async: true

  alias Phoenix.PubSub

  alias Ximula.AccessData
  alias Ximula.Sim.Queue
  alias Biotope.Simulation
  alias Biotope.Sim.Vegetation

  setup do
    data = start_link_supervised!(AccessData)
    Biotope.create(1, 2, data)
    %{data: data}
  end

  test "sim_items", %{data: data} do
    %{exit: failed, ok: success} = Simulation.sim_items([{0, 0}, {0, 1}], Vegetation, data)
    assert [] == failed
    assert 2 == Enum.count(success)
    assert %{vegetation: %{change: %{position: {_x, _y}, size: _size}}} = List.first(success)
  end

  test "sim_simulation", %{data: data} do
    {_time, result} = Simulation.sim_simulation({:vegetation, Vegetation}, data: data)
    assert %{error: [], ok: success, simulation: :vegetation} = result
    assert %{vegetation: %{change: %{position: {_x, _y}, size: _size}}} = List.first(success)
  end

  describe "notify sim events" do
    setup %{data: data} do
      PubSub.subscribe(Xim2.PubSub, "simulation:biotope")
      Simulation.sim_simulation({:vegetation, Vegetation}, data: data)
      :ok
    end

    test "received simulation results" do
      assert_received {:simulation_biotope, :simulation_results, {:vegetation, results}}
      assert %{vegetation: %{change: %{position: {_x, _y}, size: _size}}} = List.first(results)
    end

    test "no simulation errors received" do
      refute_received {:simulation_biotope, :simulation_errors, _}
    end

    test "received simulation summary" do
      assert_received {:simulation_biotope, :simulation_summary,
                       %{error: [], ok: success, simulation: :vegetation}}

      assert %{vegetation: %{change: %{position: {_x, _y}, size: _size}}} = List.first(success)
    end
  end

  describe "notify queue events" do
    setup %{data: data} do
      PubSub.subscribe(Xim2.PubSub, "simulation:biotope")
      Simulation.sim(%Queue{name: "test"}, data: data)
      :ok
    end

    test "received queue summary" do
      assert_received {:simulation_biotope, :queue_summary,
                       %{
                         queue: "test",
                         results: %{
                           vegetation: %{errors: 0, ok: 2, time: _},
                           herbivore: %{errors: 0, ok: 1, time: _},
                           predator: %{errors: 0, ok: 0, time: _}
                         }
                       }}
    end
  end
end
