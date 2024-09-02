defmodule AstrorunnerTest do
  use ExUnit.Case
  doctest Astrorunner

  alias Phoenix.PubSub
  alias Astrorunner.{Card, Board, Deck}

  setup do
    Astrorunner.clear()
    PubSub.subscribe(Xim2.PubSub, "astrorunner")
    on_exit(fn -> PubSub.unsubscribe(Xim2.PubSub, "astrorunner") end)
    :ok
  end

  test "setup" do
    {:ok, _pid} = Astrorunner.setup(["one"])
    assert_receive(:setup_done)
    board = Agent.get(Board, & &1)
    assert %{cards: %{pilots: pilots, level_1: _level_1}} = board.global
    assert %Deck{} = pilots
    assert %Card{} = pilots.draw_pile |> List.first()
    assert [] = get_in(board, [:users, "one", :crew])
  end

  test "get global cards" do
    {:ok, _pid} = Astrorunner.setup(["one"])
    assert_receive(:setup_done)
    %{pilots: pilots, level_1: level_1} = Astrorunner.get_global_decks()
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
