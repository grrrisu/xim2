defmodule Biotope.Sim.VegetationTest do
  use ExUnit.Case, async: true

  alias Ximula.AccessData
  alias Biotope.Data
  alias Biotope.Sim.Vegetation

  test "grow vegetation" do
    %{size: size} = Vegetation.grow(%Vegetation{size: 650})
    assert 650 < size
  end

  test "sim" do
    data = start_supervised!(AccessData)
    {:ok, _biotope} = Data.create(1, 1, data)
    assert {{0, 0}, %{size: size}} = Vegetation.sim({0, 0}, data: data)
    assert 650 < size
  end
end
