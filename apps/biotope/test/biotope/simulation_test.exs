defmodule Biotope.SimulationTest do
  use ExUnit.Case, async: true

  alias Phoenix.PubSub

  alias Ximula.AccessProxy
  alias Biotope.Data
  alias Biotope.Simulation
  alias Biotope.Sim.Vegetation

  setup do
    data = start_link_supervised!({Data, name: Biotope.SimulationTest})

    proxy =
      start_link_supervised!(
        {AccessProxy, name: Biotope.SimulationTest.Proxy, agent: Biotope.SimulationTest}
      )

    PubSub.subscribe(Xim2.PubSub, "Biotope:simulation")
    Biotope.create(4, 2, proxy)
    %{data: data, proxy: proxy}
  end

  test "sim vegetation", %{proxy: proxy} do
    {_time, result} = Simulation.sim_simulation(Vegetation, data: proxy)
    assert %{error: [], ok: [{_x, _y} | _], simulation: Vegetation} = result
    ok = result.ok
    assert_received(%{changed: ^ok, simulation: Vegetation})
  end
end
