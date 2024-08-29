defmodule Astrorunner.BoardTest do
  use ExUnit.Case, async: true

  alias Astrorunner.Board

  test "handle_global_setup" do
    %{cards: %{pilots: pilot_deck, level_1: level_1_deck}} = Board.handle_global_setup()
    assert 8 - 4 == Enum.count(level_1_deck.draw_pile)
    assert 15 - 4 == Enum.count(pilot_deck.draw_pile)
  end

  test "handle_inital_state" do
    assert %{global: %{cards: nil}, users: %{}} = Board.handle_initial_state()
  end
end
