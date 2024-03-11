defmodule Biotope.DataTest do
  use ExUnit.Case, async: true

  alias Ximula.AccessData
  alias Ximula.Grid
  alias Biotope.Data
  # alias Biotope.Sim.Vegetation

  setup do
    %{data: start_link_supervised!(AccessData)}
  end

  describe "create" do
    test "create", %{data: data} do
      assert nil == Data.all(data)
      assert {:ok, biotope} = Data.create(2, 1, data)
      assert %{vegetation: vegetation} = biotope
      assert 2 == Grid.width(vegetation)
      assert 1 == Grid.height(vegetation)
    end

    test "only create once", %{data: data} do
      assert {:ok, _biotope} = Data.create(2, 1, data)
      assert {:error, _msg} = Data.create(2, 1, data)
    end

    test "created?", %{data: data} do
      assert false == Data.created?(data)
      {:ok, _biotope} = Data.create(2, 1, data)
      assert true == Data.created?(data)
    end
  end

  describe "get" do
    setup %{data: data} do
      {:ok, _biotope} = Data.create(2, 3, data)
    end

    test "get grid positions", %{data: data} do
      assert {2, 3} = Data.get_grid_dimensions(data)

      assert [{0, 0}, {0, 1}, {0, 2}, {1, 0}, {1, 1}, {1, 2}] ==
               data |> Data.get_grid_dimensions() |> Data.get_grid_positions()
    end
  end
end
