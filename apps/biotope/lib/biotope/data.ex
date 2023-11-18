defmodule Biotope.Data do
  use Agent

  alias Ximula.Grid
  alias Ximula.AccessProxy

  alias Biotope.Sim.Vegetation
  alias Biotope.Sim.Animal.{Herbivore, Predator}

  def start_link(opts) do
    Agent.start_link(fn -> nil end, name: opts[:name] || __MODULE__)
  end

  def all(proxy) do
    AccessProxy.get(proxy)
  end

  def get(layer, proxy) do
    case AccessProxy.get(proxy) do
      nil -> nil
      biotope -> Map.fetch!(biotope, layer)
    end
  end

  def exclusive_get(layer, proxy) do
    case AccessProxy.exclusive_get(proxy) do
      nil -> nil
      biotope -> Map.fetch!(biotope, layer)
    end
  end

  def create(width, height, proxy) do
    case AccessProxy.exclusive_get(proxy) do
      nil ->
        :ok = AccessProxy.update(proxy, fn _ -> create_biotope(width, height) end)
        {:ok, AccessProxy.get(proxy)}

      _ ->
        AccessProxy.release(proxy)
        {:error, "already exists"}
    end
  end

  def update(:vegetation, changes, proxy) do
    AccessProxy.update(proxy, fn %{vegetation: grid} = data ->
      %{data | vegetation: Grid.apply_changes(grid, changes)}
    end)
  end

  def clear(proxy) do
    AccessProxy.exclusive_get(proxy)
    AccessProxy.update(proxy, nil)
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

    positions =
      Enum.map(0..(height - 1), fn y -> Enum.map(0..(width - 1), fn x -> {x, y} end) end)
      |> List.flatten()

    Enum.reduce(0..amount, {positions, []}, fn _, {remaining, animals} ->
      index = Enum.random(0..(Enum.count(remaining) - 1))
      {position, remaining} = List.pop_at(remaining, index)
      {remaining, [create_func.(position) | animals]}
    end)
    |> Tuple.to_list()
    |> List.last()
  end
end
