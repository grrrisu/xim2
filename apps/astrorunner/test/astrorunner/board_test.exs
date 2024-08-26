defmodule Astrorunner.BoardTest do
  use ExUnit.Case, async: true

  alias Astrorunner.Board
  alias Astrorunner.Card

  test "handle_global_setup" do
    %{cards: %{level_1: cards}} = Board.handle_global_setup()
    assert 4 == Enum.count(cards)
    assert %Card{title: "Labor Assistent"} = Enum.at(cards, 0)
  end
end
