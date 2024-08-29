defmodule Astrorunner do
  @moduledoc """
  Digital version of the boardgame *Astrorunner*
  """

  alias Phoenix.PubSub
  alias Astrorunner.{Board, Deck}

  def setup() do
    {:ok, _pid} =
      Task.start(fn ->
        Board.global_setup()
        :ok = PubSub.broadcast(Xim2.PubSub, "astrorunner", :setup_done)
      end)
  end

  def global_board() do
    Board.global_board()
  end

  def get_global_decks() do
    Board.get_global(&fun_get_global_decks(&1))
  end

  def take_revealed_card([name: _name, index: _index, player: _player] = params) do
    Board.update_global_board(&fun_take_revealed_card(&1, &2), params)
  end

  def fun_get_global_decks(global) do
    global
    |> Map.get(:cards)
    |> Enum.reduce(%{}, fn {key, value}, res ->
      Map.put_new(res, key, value.revealed)
    end)
  end

  def fun_take_revealed_card(global, name: name, index: index, player: _player) do
    with deck when not is_nil(deck) <- Map.get(global.cards, name),
         {card, deck} <- Deck.take(deck, index) do
      {card, put_in(global, [:cards, name], deck)}
    else
      _ -> {{:error, "failed to take card from deck #{name} at position #{index}"}, global}
    end
  end
end
