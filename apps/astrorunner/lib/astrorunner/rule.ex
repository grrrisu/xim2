defmodule Astrorunner.Rule do
  @moduledoc """
  The rules of the game
  """

  alias Astrorunner.{Board, Card, Deck}

  @doc """
  Player takes a card from the job market, pays its cost and places it in his player tableau
  """
  def take_card_from_job_market(deck, card_id, tableau) do
    with true <- can_take_card?(deck, card_id, tableau),
         {%Card{} = card, deck} <- Deck.take(deck, card_id),
         tableau <- add_card_to_tableau(tableau, card) do
      {:ok, {deck, tableau}}
    else
      _ -> {:error, "taking card from job market failed"}
    end
  end

  def can_take_card?(_deck, _card_id, _tableau) do
    true
  end

  def add_card_to_tableau(tableau, card) do
    place = Board.tableau_place(card)
    Map.put(tableau, place, [card | Map.get(tableau, place)])
  end
end
