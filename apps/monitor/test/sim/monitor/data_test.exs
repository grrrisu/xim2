defmodule Sim.Monitor.DataTest do
  use ExUnit.Case, async: true

  alias Sim.Monitor.Data

  setup do
    agent = start_link_supervised!(Ximula.Gatekeeper.Agent.agent_spec(Data, name: __MODULE__))
    %{data: start_link_supervised!({Ximula.Gatekeeper.Server, context: %{agent: agent}})}
  end

  test "create monitor data", %{data: data} do
    Data.create(data, 10)
    assert 0 == data |> Data.get(2) |> Map.get(:value)
  end
end
