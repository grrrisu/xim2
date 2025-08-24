defmodule Biotope.SimulationTest do
  use ExUnit.Case, async: true

  alias Phoenix.PubSub

  alias Ximula.Sim.Queue
  alias Biotope.Simulation
  alias Biotope.Sim.Vegetation

  setup do
    agent = start_link_supervised!(Ximula.Gatekeeper.Agent.agent_spec(Data, name: __MODULE__))
    data = start_link_supervised!({Ximula.Gatekeeper.Server, context: %{agent: agent}})
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

    test "no simulation errors received" do
      refute_received {:simulation_biotope, :simulation_errors, _}
    end
  end

  describe "notify queue events" do
    setup %{data: data} do
      PubSub.subscribe(Xim2.PubSub, "simulation:biotope")
      Simulation.sim(%Queue{name: "test"}, data: data)
      :ok
    end

    test "changed entities received" do
      assert_received {:simulation_biotope, :entities_changed,
                       %{vegetation: vegetation, herbivore: herbivore, predator: predator}}

      assert 2 == Enum.count(vegetation)
      assert 1 == Enum.count(herbivore)
      assert Enum.empty?(predator)
    end

    test "received queue summary" do
      assert_received {:simulation_biotope, :queue_summary,
                       %{
                         queue: "test",
                         results: %{
                           vegetation: %{error: 0, ok: 2, time: _},
                           herbivore: %{error: 0, ok: 1, time: _},
                           predator: %{error: 0, ok: 0, time: _}
                         }
                       }}
    end
  end
end
