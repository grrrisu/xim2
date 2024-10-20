defmodule Astrorunner.Deck do
  @moduledoc """
  Deck consists of cards. They can be in 3 different places: in the draw pile, revealed or in the discard pile.
  """

  alias Astrorunner.{Card, Deck}

  defstruct draw_pile: [], revealed: [], discard_pile: []

  def setup(cards, revealed \\ []) do
    %Deck{draw_pile: cards, revealed: revealed} |> shuffle_draw_pile()
  end

  def shuffle_draw_pile(%Deck{draw_pile: draw_pile} = deck) do
    %{deck | draw_pile: Enum.shuffle(draw_pile)}
  end

  @doc "draw cards from the draw pile"
  def draw(deck, demand \\ 1)

  def draw(%Deck{draw_pile: [], discard_pile: []} = deck, _n), do: {[], deck}

  def draw(%Deck{draw_pile: draw_pile} = deck, demand) do
    draw(deck, demand, Enum.count(draw_pile))
  end

  def draw(%Deck{draw_pile: remaining, discard_pile: discard_pile} = deck, demand, available)
      when available < demand do
    %{deck | draw_pile: discard_pile, discard_pile: []}
    |> shuffle_draw_pile()
    |> draw(demand - available)
    |> then(fn {taken, deck} -> {remaining ++ taken, deck} end)
  end

  def draw(%Deck{draw_pile: draw_pile} = deck, demand, _available) do
    {taken, remaining} = Enum.split(draw_pile, demand)
    {taken, %{deck | draw_pile: remaining}}
  end

  def draw_one(deck) do
    {taken, deck} = draw(deck)
    {List.first(taken), deck}
  end

  @doc "reveal cards from the draw pile and put them to the revealed row"
  def reveal(%Deck{} = deck, n \\ 1) do
    {taken, deck} = draw(deck, n)
    %{deck | revealed: deck.revealed ++ taken}
  end

  @doc """
  reveal cards from the draw pile up to the size of the row
  """
  def reveal_up_to(%Deck{revealed: revealed} = deck, size \\ 1) do
    case size - Enum.count(revealed) do
      n when n > 0 -> reveal(deck, n)
      _ -> deck
    end
  end

  def take_at(deck, index \\ 0)

  def take_at(%Deck{} = deck, nil), do: {nil, deck}

  @doc "take a card from the revealed row"
  def take_at(%Deck{revealed: revealed} = deck, index) when is_integer(index) do
    {taken, remaining} = List.pop_at(revealed, index)
    {taken, %{deck | revealed: remaining}}
  end

  @doc "take a card from the revealed row"
  def take(%Deck{revealed: revealed} = deck, id) do
    take_at(deck, Enum.find_index(revealed, &(&1.id == id)))
  end

  @doc "take a card from the revelead row and replace it with one from the draw pile"
  def take_at_and_replace(%Deck{} = deck, index \\ 0) do
    {taken, deck} = take_at(deck, index)
    {taken, reveal(deck)}
  end

  @doc "take a card from the revelead row and replace it with one from the draw pile"
  def take_and_replace(%Deck{} = deck, id) do
    {taken, deck} = take(deck, id)
    {taken, reveal(deck)}
  end

  @doc "add a card to the revealed row"
  def add(%Deck{revealed: revealed} = deck, %Card{} = card) do
    %Deck{deck | revealed: revealed ++ [card]}
  end
end
