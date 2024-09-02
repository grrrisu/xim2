defmodule Astrorunner do
  @moduledoc """
  Digital version of the boardgame *Astrorunner*
  """

  alias Phoenix.PubSub
  alias Astrorunner.{Board, Rule}

  def setup(players \\ []) do
    {:ok, _pid} =
      Task.start(fn ->
        Board.setup(players)
        :ok = PubSub.broadcast(Xim2.PubSub, "astrorunner", :setup_done)
      end)
  end

  defdelegate clear(), to: Board
  defdelegate global_board(), to: Board

  def get_global_decks() do
    Board.get_global(&fun_get_global_decks(&1))
  end

  def fun_get_global_decks(global) do
    global
    |> Map.get(:cards)
    |> Enum.reduce(%{}, fn {key, value}, res ->
      Map.put_new(res, key, value.revealed)
    end)
  end

  def take_revealed_card(player: player, name: name, index: index) do
    with {deck, tableau} when not is_nil(deck) and not is_nil(tableau) <-
           Board.get_deck_and_player_tableau(name, player),
         {:ok, {deck, tableau}} <- Rule.take_card_from_job_market(deck, index, tableau) do
      Board.put_deck_and_player_tableau({name, deck}, {player, tableau})
    else
      {:error, reason} -> {:error, reason}
      _ -> {:error, "taking card failed!"}
    end
  end
end
