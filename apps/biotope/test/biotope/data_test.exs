defmodule Biotope.DataTest do
  use ExUnit.Case, async: true

  alias Ximula.AccessData
  alias Ximula.Grid
  alias Biotope.Data
  alias Biotope.Sim.Vegetation

  setup do
    %{data: start_link_supervised!(AccessData)}
  end

  test "create", %{data: data} do
    assert nil == Data.all(data)
    assert {:ok, biotope} = Data.create(2, 1, data)
    assert %{vegetation: vegetation} = biotope
    assert 2 == Grid.width(vegetation)
    assert 1 == Grid.height(vegetation)
  end
end
