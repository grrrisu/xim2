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
        AccessProxy.update(proxy, fn -> create_grid(width, height) end)

      _ ->
        AccessProxy.release(proxy)
        {:error, "already exists"}
    end
  end

  defp create_grid(width, height) do
    Grid.create(width, height, %{vegetation: %{size: 10}})
  end
end
