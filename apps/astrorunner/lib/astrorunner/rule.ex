defmodule Astrorunner.Rule do
  @moduledoc """
  The rules of the game
  """

  alias Astrorunner.{Board, Deck}

  @doc """
  Player takes a card from the job market, pays its cost and places it in his player tableau
  """
  def take_card_from_job_market(deck, index, tableau) do
    with true <- can_take_card?(deck, index, tableau),
         {card, deck} <- Deck.take(deck, index),
         tableau <- add_card_to_tableau(tableau, card) do
      {:ok, {deck, tableau}}
    else
      _ -> {:error, "taking card failed"}
    end
  end

  def can_take_card?(deck, index, tableau) do
    true
  end

  def add_card_to_tableau(tableau, card) do
    place = Board.tableau_place(card)
    Map.put(tableau, place, [card | Map.get(tableau, place)])
  end
end
