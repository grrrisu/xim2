defmodule Astrorunner.DeckTest do
  use ExUnit.Case, async: true

  alias Astrorunner.Deck

  @draw_deck %Deck{draw_pile: [1, 2, 3, 4, 5], revealed: [], discard_pile: []}
  @revealed_deck %Deck{draw_pile: [1, 2], revealed: [3, 4], discard_pile: [5, 6]}
  @discarded_deck %Deck{draw_pile: [], revealed: [], discard_pile: [1, 2, 3, 4, 5]}
  @empty_deck %Deck{draw_pile: [], revealed: [], discard_pile: []}

  describe "shuffle deck" do
    test "full deck" do
      assert %Deck{draw_pile: draw_pile, revealed: [], discard_pile: []} =
               Deck.shuffle_draw_pile(@draw_deck)

      assert [] == draw_pile -- @draw_deck.draw_pile
    end

    test "empty deck" do
      assert %Deck{draw_pile: [], revealed: [], discard_pile: []} =
               Deck.shuffle_draw_pile(@empty_deck)
    end
  end

  describe "draw card" do
    test "just one" do
      assert {[1], %Deck{draw_pile: remaining}} = Deck.draw(@draw_deck)
      assert 4 == Enum.count(remaining)
    end

    test "three" do
      assert {[1, 2, 3], %Deck{draw_pile: remaining}} = Deck.draw(@draw_deck, 3)
      assert 2 == Enum.count(remaining)
    end

    test "empty deck" do
      assert {[], @empty_deck} = Deck.draw(@empty_deck)
    end

    test "readd discard pile" do
      assert {taken, %Deck{draw_pile: remaining, discard_pile: []}} =
               Deck.draw(@discarded_deck, 3)

      assert 3 == Enum.count(taken)
      assert 2 == Enum.count(remaining)
    end

    test "draw remaining and readd discard pile" do
      assert {[1, 2, x], %Deck{draw_pile: remaining, discard_pile: []}} =
               Deck.draw(%Deck{draw_pile: [1, 2], discard_pile: [3, 4, 5]}, 3)

      assert Enum.member?(@discarded_deck.discard_pile, x)
      assert 2 == Enum.count(remaining)
    end

    test "draw too much" do
      assert {[1, 2, 3, 4, 5], %Deck{draw_pile: []}} = Deck.draw(@draw_deck, 10)
    end

    test "draw_one" do
      assert {1, %Deck{}} = Deck.draw_one(@draw_deck)
    end
  end

  describe "reveal card" do
    test "just one" do
      assert %Deck{draw_pile: remaining, revealed: [1], discard_pile: []} =
               Deck.reveal(@draw_deck)

      assert 4 == Enum.count(remaining)
    end

    test "another two" do
      assert %Deck{draw_pile: [], revealed: [3, 4, 1, 2], discard_pile: [5, 6]} =
               Deck.reveal(@revealed_deck, 2)
    end

    test "up to four" do
      assert %Deck{draw_pile: [], revealed: [3, 4, 1, 2], discard_pile: [5, 6]} =
               Deck.reveal_up_to(@revealed_deck, 4)
    end

    test "another two after readd discard pile" do
      assert %Deck{draw_pile: remaining, revealed: revealed, discard_pile: []} =
               Deck.reveal(@discarded_deck, 2)

      assert 3 = Enum.count(remaining)
      assert 2 = Enum.count(revealed)
    end

    test "another three after readd discard pile" do
      assert %Deck{draw_pile: [x], revealed: [3, 4, 1, 2, y], discard_pile: []} =
               Deck.reveal(@revealed_deck, 3)

      assert Enum.member?(@revealed_deck.discard_pile, x)
      assert Enum.member?(@revealed_deck.discard_pile, y)
    end
  end

  describe "take card" do
    test "first" do
      assert {3, %Deck{revealed: [4]}} = Deck.take(@revealed_deck)
    end

    test "second" do
      assert {4, %Deck{revealed: [3]}} = Deck.take(@revealed_deck, 1)
    end

    test "second and replace" do
      assert {4, %Deck{revealed: [3, 1]}} = Deck.take_and_replace(@revealed_deck, 1)
    end
  end
end
