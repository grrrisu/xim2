defmodule Astrorunner do
  @moduledoc """
  Digital version of the boardgame *Astrorunner*
  """

  alias Phoenix.PubSub
  alias Astrorunner.{Board, Rule}

  def setup(players \\ [], server \\ Board) do
    {:ok, _pid} =
      Task.start(fn ->
        Board.setup(players, server)
        :ok = PubSub.broadcast(Xim2.PubSub, "astrorunner", :setup_done)
      end)
  end

  defdelegate clear(server \\ Board), to: Board
  defdelegate get(func \\ &board_for_ui(&1), server \\ Board), to: Board

  def board_for_ui(state) do
    state
    |> put_in([:global, :cards], fun_get_global_decks(state.global))
  end

  def fun_get_global_decks(%{cards: nil}), do: nil

  def fun_get_global_decks(%{cards: cards}) do
    cards
    |> Enum.reduce(%{}, fn {key, value}, res ->
      Map.put_new(res, key, value.revealed)
    end)
  end

  def take_revealed_card(server \\ Board, player: player, name: name, card_id: card_id) do
    with {deck, tableau} when not is_nil(deck) and not is_nil(tableau) <-
           Board.get_deck_and_player_tableau(name, player, server),
         {:ok, {deck, tableau}} <- Rule.take_card_from_job_market(deck, card_id, tableau) do
      Board.put_deck_and_player_tableau({name, deck}, {player, tableau}, server)
    else
      {:error, reason} -> {:error, reason}
      _ -> {:error, "taking card failed!"}
    end
  end
end
