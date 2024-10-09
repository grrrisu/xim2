defmodule Astrorunner.RuleTest do
  use ExUnit.Case, async: true

  alias Astrorunner.{Card, Deck, Rule}

  describe "take_card_from_job_market" do
    test "is possible" do
      [one, two, three] = Card.build(:stuntmen, 3)

      deck = Deck.setup([], [one, two, three])
      tableau = %{crew: []}

      assert {:ok, {deck, tableau}} =
               Rule.take_card_from_job_market(
                 deck,
                 two.id,
                 tableau
               )

      assert 2 == Enum.count(deck.revealed)
      assert 1 == Enum.count(tableau.crew)
    end

    test "not enough money" do
    end
  end
end
