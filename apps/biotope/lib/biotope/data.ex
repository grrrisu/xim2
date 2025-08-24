defmodule Biotope.Data do
  alias Ximula.{Grid, Torus}
  alias Ximula.Gatekeeper.Agent, as: Gatekeeper

  alias Biotope.Sim.Vegetation
  alias Biotope.Sim.Animal.{Herbivore, Predator}

  def start_link(opts) do
    Agent.start_link(fn -> nil end, name: opts[:name] || __MODULE__)
  end

  def all(data) do
    Gatekeeper.get(data, & &1)
  end

  def get(layer, data) do
    case all(data) do
      nil -> nil
      biotope -> Map.fetch!(biotope, layer)
    end
  end

  def get_grid_dimensions(data) do
    Gatekeeper.get(data, fn biotope ->
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
    Gatekeeper.get(data, fn biotope -> field({x, y}, layer, biotope) end)
  end

  def lock_field({x, y}, layer, data) do
    Gatekeeper.lock(data, {x, y}, fn biotope -> field({x, y}, layer, biotope) end)
  end

  def lock_herbivore(position, data) do
    Gatekeeper.lock(data, position, fn biotope ->
      %{
        vegetation: field(position, :vegetation, biotope),
        herbivore: entity(position, :herbivore, biotope)
      }
    end)
  end

  def lock_predator(position, data) do
    Gatekeeper.lock(data, position, fn biotope ->
      %{
        herbivore: entity(position, :herbivore, biotope),
        predator: entity(position, :predator, biotope)
      }
    end)
  end

  def field({x, y}, layer, biotope) do
    biotope |> Map.fetch!(layer) |> Torus.get(x, y)
  end

  def entity(position, layer, biotope) do
    get_in(biotope, [layer, position])
  end

  def get_layer_positions(layer, data) do
    Gatekeeper.get(data, fn biotope ->
      case Map.get(biotope, layer) do
        nil -> []
        entities -> Map.keys(entities)
      end
    end)
  end

  def created?(data) do
    Gatekeeper.get(data, &(!is_nil(&1)))
  end

  def create(width, height, data) do
    if created?(data) do
      {:error, "already exists"}
    else
      :ok = Gatekeeper.direct_set(data, fn _ -> create_biotope(width, height) end)
      {:ok, all(data)}
    end
  end

  def update(%Vegetation{} = vegetation, position, data) do
    :ok =
      Gatekeeper.update(data, position, nil, fn %{vegetation: grid} = data ->
        %{data | vegetation: Grid.put(grid, position, vegetation)}
      end)

    vegetation
  end

  def update({%Vegetation{} = vegetation, %Herbivore{} = herbivore}, position, data) do
    :ok =
      Gatekeeper.update(data, position, nil, fn %{vegetation: grid} = biotope ->
        biotope
        |> Map.put(:vegetation, Grid.put(grid, position, vegetation))
        |> put_in([:herbivore, position], herbivore)
      end)
  end

  def update({%Herbivore{} = herbivore, %Predator{} = predator}, position, data) do
    :ok =
      Gatekeeper.update(data, position, nil, fn biotope ->
        biotope
        |> put_in([:herbivore, position], herbivore)
        |> put_in([:predator, position], predator)
      end)
  end

  def clear(data) do
    Gatekeeper.direct_set(data, fn _ -> nil end)
  end

  defp create_biotope(width, height) do
    %{
      vegetation: Grid.create(width, height, fn x, y -> %Vegetation{position: {x, y}} end),
      herbivore:
        create_animals(width, height, 0.1, fn position -> %Herbivore{position: position} end)
      # predator:
      #  create_animals(width, height, 0.02, fn position -> %Predator{position: position} end)
    }
  end

  defp create_animals(width, height, percent, create_func) do
    amount = round(width * height * percent)
    positions = get_grid_positions({width, height})

    Enum.reduce(0..amount, {positions, %{}}, fn _, {remaining, animals} ->
      index = Enum.random(0..(Enum.count(remaining) - 1))
      {position, remaining} = List.pop_at(remaining, index)
      {remaining, Map.put_new(animals, position, create_func.(position))}
    end)
    |> elem(1)
  end
end
