defmodule AstrorunnerTest do
  use ExUnit.Case
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

  @data %{
    global: %{cards: %{pilots: Deck.setup(Card.build(:stuntmen), Card.build(:line_pilot, 4))}},
    users: %{"one" => %{crew: []}}
  }
  describe "take revealed card" do
    test "and adds it to his tableau" do
      Agent.update(Board, fn _ -> @data end)

      assert {%Deck{}, %{crew: [%Card{}]}} =
               Astrorunner.take_revealed_card(player: "one", name: :pilots, index: 3)
    end

    test "returns an error" do
      Agent.update(Board, fn _ -> @data end)

      assert {:error, _msg} =
               Astrorunner.take_revealed_card(player: "one", name: :unknown, index: 3)
    end
  end
end
