defmodule Sim.Monitor.DataTest do
  use ExUnit.Case, async: true

  alias Ximula.AccessData

  alias Sim.Monitor.Data

  setup do
    %{data: start_link_supervised!(AccessData)}
  end

  test "create monitor data", %{data: data} do
    Data.create(data, 10)
    assert 0 == data |> Data.get(2) |> Map.get(:value)
  end
end
