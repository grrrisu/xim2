defmodule Biotope.Sim.Vegetation do
  def sim({position, %{size: size}}) do
    {position, %{size: size + 1}}
  end
end
