defmodule Sim.Monitor do
  @moduledoc """
  Context for `Sim.Monitor`.
  """

  alias Sim.Monitor.Data

  def create_data(size) do
    Data.create(Sim.Monitor.Data, size)
  end

  def get_data(key) do
    Data.get(Sim.Monitor.Data, key)
  end
end
