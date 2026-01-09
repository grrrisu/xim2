defmodule Biotope.Sim.VegetationTest do
  use ExUnit.Case, async: true

  alias Ximula.Sim.Change
  alias Biotope.Sim.Vegetation

  test "grow vegetation" do
    %{size: size} = Vegetation.grow(%Vegetation{size: 650})
    assert 0 < size
  end

  test "sim" do
    assert 650 <
             %Change{data: %Vegetation{size: 650}}
             |> Vegetation.sim()
             |> Change.get(:size)
  end
end
