defmodule Biotope.Sim.Vegetation do
  use Accessible

  alias Ximula.Sim.Change

  alias Biotope.Sim.Vegetation

  defstruct position: {0, 0},
            capacity: 6000,
            birth_rate: 0.15,
            death_rate: 0.05,
            size: 650.0,
            display_size: 650,
            priority: :normal

  def sim(%Change{} = change) do
    delta = grow(change.data)
    Change.change_by(change, :size, delta.size)
  end

  # vegetation grows by birth rate (alias grow rate) and shrinks by natural deaths (age),
  # the vegetation size is limited by the capacity (available room, sun energy)
  #
  # b : birth_rate
  # d : death_rate
  # C : capacity
  # s : size
  #
  # Δ &#916;
  #
  #                (C - s)
  # Δs = s (b - d) -------
  #                  C
  def delta(%Vegetation{
        capacity: capacity,
        birth_rate: birth_rate,
        death_rate: death_rate,
        size: size
      }) do
    size * (birth_rate - death_rate) * (capacity - size) / capacity
  end

  def grow(%Vegetation{} = vegetation, step \\ 1) do
    %{size: delta(vegetation) * step}
  end
end
