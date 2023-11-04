defmodule Biotope.Data do
  use Agent

  alias Ximula.Grid
  alias Ximula.AccessProxy

  def start_link(opts) do
    Agent.start_link(fn -> nil end, name: opts[:name] || __MODULE__)
  end

  def get(proxy) do
    AccessProxy.get(proxy)
  end

  def create(width, height, proxy) do
    case AccessProxy.exclusive_get(proxy) do
      nil ->
        :ok = AccessProxy.update(proxy, fn _ -> create_grid(width, height) end)
        {:ok, AccessProxy.get(proxy)}

      _ ->
        AccessProxy.release(proxy)
        {:error, "already exists"}
    end
  end

  def clear(proxy) do
    AccessProxy.exclusive_get(proxy)
    AccessProxy.update(proxy, nil)
  end

  defp create_grid(width, height) do
    Grid.create(width, height, %{vegetation: %{size: 10}})
  end
end
