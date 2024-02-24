defmodule Sim.Monitor.Data do
  @moduledoc """
  the simulation dummy data
  """

  alias Ximula.AccessData

  def create(server, size) do
    :ok = AccessData.lock(:all, server)
    data = 0..size |> Enum.reduce(%{}, &Map.put_new(&2, &1, %{value: 0}))
    AccessData.update(:all, data, server, fn _data, _key, _value -> data end)
  end

  def get(server, key) do
    AccessData.get_by(server, &Map.get(&1, key))
  end
end
