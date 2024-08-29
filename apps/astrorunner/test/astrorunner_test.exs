defmodule AstrorunnerTest do
  use ExUnit.Case, async: true
  doctest Astrorunner

  alias Astrorunner.{Card, Board, Deck}

  setup do
    %{board: Board.handle_global_setup()}
  end

  test "setup", %{board: board} do
    assert %{cards: %{pilots: pilots, level_1: _level_1}} = board
    assert %Deck{} = pilots
    assert %Card{} = pilots.draw_pile |> List.first()
  end

  test "get global cards", %{board: board} do
    %{pilots: pilots, level_1: level_1} = Astrorunner.fun_get_global_decks(board)
    assert 4 == Enum.count(pilots)
    assert 4 == Enum.count(level_1)
    assert %Card{} = List.first(pilots)
  end

  describe "take revealed card" do
    test "returns the taken card", %{board: board} do
      assert {%Card{}, _new_board} =
               Astrorunner.fun_take_revealed_card(board, name: :pilots, index: 1, player: "one")
    end

    test "returns an error", %{board: board} do
      assert {{:error, _msg}, ^board} =
               Astrorunner.fun_take_revealed_card(board, name: :unknown, index: 1, player: "one")
    end
  end
end
