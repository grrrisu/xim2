defmodule Biotope.Data do
  use Agent

  alias Ximula.Grid
  alias Ximula.AccessProxy

  def start_link(opts) do
    Agent.start_link(fn -> nil end, name: opts[:name] || __MODULE__)
  end

  def get(proxy) do
    case AccessProxy.get(proxy) do
      nil -> nil
      biotope -> Map.fetch!(biotope, :vegetation)
    end
  end

  def exclusive_get(proxy) do
    case AccessProxy.exclusive_get(proxy) do
      nil -> nil
      biotope -> Map.fetch!(biotope, :vegetation)
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

  def update(changes, proxy) do
    AccessProxy.update(proxy, fn %{vegetation: grid} = data ->
      %{data | vegetation: Grid.apply_changes(grid, changes)}
    end)
  end

  def clear(proxy) do
    AccessProxy.exclusive_get(proxy)
    AccessProxy.update(proxy, nil)
  end

  defp create_biotope(width, height) do
    %{vegetation: Grid.create(width, height, %{size: 10})}
  end
end
