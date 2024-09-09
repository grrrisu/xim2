defmodule AstrorunnerTest do
  use ExUnit.Case
  doctest Astrorunner

  alias Phoenix.PubSub
  alias Astrorunner.{Card, Board, Deck}

  @data %{
    global: %{cards: %{pilots: Deck.setup(Card.build(:stuntmen), Card.build(:line_pilot, 4))}},
    players: %{"one" => %{crew: []}}
  }

  setup do
    # Astrorunner.clear()
    PubSub.subscribe(Xim2.PubSub, "astrorunner")
    {:ok, pid} = start_supervised(Board)
    on_exit(fn -> PubSub.unsubscribe(Xim2.PubSub, "astrorunner") end)
    %{board: pid}
  end

  test "setup", %{board: board} do
    {:ok, _pid} = Astrorunner.setup(["one"], board)
    assert_receive(:setup_done)
    board = Agent.get(board, & &1)
    assert %{cards: %{pilots: pilots, level_1: _level_1}} = board.global
    assert %Deck{} = pilots
    assert %Card{} = pilots.draw_pile |> List.first()
    assert [] = get_in(board, [:players, "one", :crew])
  end

  test "board_for_ui" do
    %{global: %{cards: %{pilots: pilots}}, players: players} = Astrorunner.board_for_ui(@data)

    assert 4 == Enum.count(pilots)
    assert %Card{} = List.first(pilots)
    assert %{"one" => %{crew: []}} = players
  end

  describe "take revealed card" do
    test "and adds it to his tableau", %{board: board} do
      Agent.update(board, fn _ -> @data end)

      assert {[%Card{} | _], %{crew: [%Card{}]}} =
               Astrorunner.take_revealed_card(board, player: "one", name: :pilots, index: 3)
    end

    test "returns an error", %{board: board} do
      Agent.update(board, fn _ -> @data end)

      assert {:error, _msg} =
               Astrorunner.take_revealed_card(board, player: "one", name: :unknown, index: 3)
    end
  end
end
