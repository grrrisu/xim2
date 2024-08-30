defmodule Astrorunner.Rule do
  @moduledoc """
  The rules of the game
  """

  @doc """
  Player takes a card from the job market, pays its cost and places it in his player tableau
  """
  def take_card_from_job_market(deck, index, tableau) do
    with true <- can_take_card?(deck, index, tableau),
         {card, deck} <- take_revealed_card(deck, index),
         tableau <- add_card_to_tableau(tableau, card) do
      {:ok, {deck, tableau}}
    else
      _ -> {:error, "taking card failed"}
    end
  end

  def can_take_card?(deck, index, tableau) do
    true
  end

  def take_revealed_card(deck, index) do
    {nil, deck}
  end

  def add_card_to_tableau(tableau, card) do
    tableau
  end
end
