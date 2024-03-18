defmodule Biotope.Sim.Vegetation do
  alias Biotope.Data

  alias Biotope.Sim.Vegetation

  defstruct position: {0, 0},
            capacity: 6000,
            birth_rate: 0.15,
            death_rate: 0.05,
            size: 650.0,
            display_size: 650,
            priority: :normal

  def sim(position, data: data) do
    %{key: position, data: data}
    |> Map.put_new(:origin, Data.lock_field(position, :vegetation, data))
    |> then(&Map.put_new(&1, :change, grow(&1.origin)))
    |> then(&Map.put(&1, :change, set_position(&1.change, position)))
    |> update_data()
    |> result()
  end

  def set_position(change, position) do
    Map.put_new(change, :position, position)
  end

  def round_size(%{size: size} = change) do
    Map.put_new(change, :display_size, round(size))
  end

  def has_changed?(%{change: %{display_size: size}, origin: %{display_size: previous_size}}) do
    size - previous_size != 0
  end

  def set_queue(%{changed: true} = changeset),
    do: put_in(changeset, [:change, :priority], :normal)

  def set_queue(%{changed: false} = changeset),
    do: put_in(changeset, [:change, :priority], :low)

  def update_data(%{key: position, data: data, origin: vegetation, change: change} = changeset) do
    vegetation
    |> Map.merge(change)
    |> Data.update(position, data)

    changeset
  end

  def result(%{change: change, origin: origin}) do
    %{vegetation: %{change: change, origin: origin}}
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

  def grow(%Vegetation{size: size} = vegetation, step \\ 1) do
    %{size: size + delta(vegetation) * step}
  end
end
