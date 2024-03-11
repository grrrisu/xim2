defmodule Biotope.SimulationTest do
  use ExUnit.Case, async: true

  alias Phoenix.PubSub

  alias Ximula.AccessData
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
    assert {{_x, _y}, %{size: _size}} = List.first(success)
  end

  test "sim_simulation", %{data: data} do
    {_time, result} = Simulation.sim_simulation({:vegetation, Vegetation}, data: data)
    assert %{error: [], ok: success, simulation: :vegetation} = result
    assert {_x, _y} = List.first(success)
  end

  describe "notify listener" do
    setup %{data: data} do
      PubSub.subscribe(Xim2.PubSub, "Simulation:biotope")
      Simulation.sim_simulation({:vegetation, Vegetation}, data: data)
      :ok
    end

    test "receives simulation results" do
      assert_received {:simulation_biotope, :simulation_results, {:vegetation, results}}
      assert {{_x, _y}, %{size: _size}} = List.first(results)
    end

    test "receives simulation errors" do
      assert_received {:simulation_biotope, :simulation_errors, {:vegetation, []}}
    end

    test "receives simulation summary" do
      assert_received {:simulation_biotope, :simulation_summary,
                       %{error: [], ok: success, simulation: :vegetation}}

      assert {_x, _y} = List.first(success)
    end
  end
end
