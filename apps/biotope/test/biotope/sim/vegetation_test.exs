defmodule Biotope.Sim.VegetationTest do
  use ExUnit.Case, async: true

  alias Biotope.Sim.Vegetation

  test "grow vegetation" do
    {{0, 5}, %Vegetation{size: size}} = Vegetation.sim({{0, 5}, %Vegetation{size: 650}})
    assert 650 < size
  end
end
