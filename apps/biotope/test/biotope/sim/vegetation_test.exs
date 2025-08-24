defmodule Biotope.Sim.VegetationTest do
  use ExUnit.Case, async: true

  alias Biotope.Data
  alias Biotope.Sim.Vegetation

  test "grow vegetation" do
    %{size: size} = Vegetation.grow(%Vegetation{size: 650})
    assert 650 < size
  end

  test "sim" do
    agent = start_link_supervised!(Ximula.Gatekeeper.Agent.agent_spec(Data, name: __MODULE__))
    data = start_link_supervised!({Ximula.Gatekeeper.Server, context: %{agent: agent}})

    {:ok, _biotope} = Data.create(1, 1, data)

    assert %{vegetation: %{change: %{position: {0, 0}, size: size}}} =
             Vegetation.sim({0, 0}, data: data)

    assert 650 < size
  end
end
