defmodule Biotope.SimulationTest do
  use ExUnit.Case, async: true

  alias Ximula.Sim.{Pipeline, Queue}
  alias Ximula.Gatekeeper.Server, as: GatekeeperServer

  alias Biotope.Simulation

  test "build pipelines" do
    assert %{biotop: %{name: :biotop, stages: [_ | _]}} = Simulation.build_pipelines()
  end

  test "execute pipeline" do
    {:ok, agent} = start_supervised({Agent, fn -> nil end})
    {:ok, gatekeeper} = start_supervised({GatekeeperServer, [context: %{agent: agent}]})
    {:ok, supervisor} = start_supervised(Task.Supervisor)

    {:ok, data} = Biotope.create(1, 1, gatekeeper)
    assert %{vegetation: _} = data

    Simulation.build_pipelines()
    |> Map.get(:biotop)
    |> put_in([:stages, Access.all(), :gatekeeper], gatekeeper)
    |> Pipeline.execute(%{
      data: [{0, 0}],
      opts: [supervisor: supervisor, gatekeeper: gatekeeper]
    })

    assert Biotope.get_field({0, 0}, :vegetation, gatekeeper) |> Map.get(:size) > 650
  end

  test "build queue" do
    assert [%Queue{name: :normal}] = Simulation.build_queues()
  end
end
