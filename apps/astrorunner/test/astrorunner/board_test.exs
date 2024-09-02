defmodule Astrorunner.BoardTest do
  use ExUnit.Case, async: true

  alias Astrorunner.{Board, Card, Deck}

  setup do
    {:ok, pid} = start_supervised(Board)
    %{board: pid}
  end

  @data %{
    global: %{cards: %{pilots: Deck.setup(Card.build(:stuntmen), Card.build(:line_pilot, 4))}},
    users: %{"deadpool" => %{crew: []}}
  }

  test "handle_global_setup" do
    %{cards: %{pilots: pilot_deck, level_1: level_1_deck}} = Board.handle_global_setup()
    assert 8 - 4 == Enum.count(level_1_deck.draw_pile)
    assert 15 - 4 == Enum.count(pilot_deck.draw_pile)
  end

  test "handle_inital_state" do
    assert %{global: %{cards: nil}, users: %{}} = Board.handle_initial_state()
  end

  test "get_deck_and_player_tableau", %{board: board} do
    Agent.update(board, fn _ -> @data end)
    assert {deck, tableau} = Board.get_deck_and_player_tableau(:pilots, "deadpool", board)
    assert 4 == Enum.count(deck.revealed)
    assert Enum.empty?(tableau.crew)
  end

  test "put_deck_and_player_tableau", %{board: board} do
    Agent.update(board, fn _ -> @data end)
    deck = Deck.setup([], Card.build(:line_pilot, 3))
    tableau = %{crew: [Card.build(:line_pilot)]}

    assert {deck, tableau} =
             Board.put_deck_and_player_tableau({:pilots, deck}, {"deadpool", tableau}, board)

    assert 3 == Enum.count(deck.revealed)
    assert 1 == Enum.count(tableau.crew)
  end
end
