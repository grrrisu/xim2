defmodule Biotope.Data do
  alias Ximula.{Grid, Torus}
  alias Ximula.AccessData

  alias Biotope.Sim.Vegetation
  alias Biotope.Sim.Animal.{Herbivore, Predator}

  def start_link(opts) do
    Agent.start_link(fn -> nil end, name: opts[:name] || __MODULE__)
  end

  def all(data) do
    AccessData.get(data, & &1)
  end

  def get(layer, data) do
    case all(data) do
      nil -> nil
      biotope -> Map.fetch!(biotope, layer)
    end
  end

  def get_grid_dimensions(data) do
    AccessData.get(data, fn biotope ->
      biotope
      |> Map.get(:vegetation)
      |> then(fn grid -> {Grid.width(grid), Grid.height(grid)} end)
    end)
  end

  def get_grid_positions({width, height}) do
    Enum.map(0..(width - 1), fn x -> Enum.map(0..(height - 1), fn y -> {x, y} end) end)
    |> List.flatten()
  end

  def get_field({x, y}, layer, data) do
    AccessData.get(data, fn biotope -> field({x, y}, layer, biotope) end)
  end

  def lock_field({x, y}, layer, data) do
    AccessData.lock({x, y}, data, fn biotope -> field({x, y}, layer, biotope) end)
  end

  def field({x, y}, layer, biotope) do
    biotope |> Map.fetch!(layer) |> Torus.get(x, y)
  end

  def exclusive_get(layer, data) do
    case AccessData.lock(:all, data, fn data, _ -> data end) do
      nil -> nil
      biotope -> Map.fetch!(biotope, layer)
    end
  end

  def created?(data) do
    AccessData.get(data, &(!is_nil(&1)))
  end

  def create(width, height, data) do
    unless created?(data) do
      :ok = AccessData.set(data, fn _ -> create_biotope(width, height) end)
      {:ok, all(data)}
    else
      {:error, "already exists"}
    end
  end

  def update(%Vegetation{} = vegetation, position, data) do
    :ok =
      AccessData.update(position, data, fn %{vegetation: grid} = data ->
        %{data | vegetation: Grid.put(grid, position, vegetation)}
      end)

    vegetation
  end

  def clear(data) do
    AccessData.set(data, fn _ -> nil end)
  end

  defp create_biotope(width, height) do
    %{
      vegetation: Grid.create(width, height, %Vegetation{}),
      herbivores:
        create_animals(width, height, 0.1, fn position -> %Herbivore{position: position} end),
      predators:
        create_animals(width, height, 0.02, fn position -> %Predator{position: position} end)
    }
  end

  defp create_animals(width, height, percent, create_func) do
    amount = round(width * height * percent)
    positions = get_grid_positions({width, height})

    Enum.reduce(0..amount, {positions, []}, fn _, {remaining, animals} ->
      index = Enum.random(0..(Enum.count(remaining) - 1))
      {position, remaining} = List.pop_at(remaining, index)
      {remaining, [create_func.(position) | animals]}
    end)
    |> Tuple.to_list()
    |> List.last()
  end
end
