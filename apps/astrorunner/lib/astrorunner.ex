defmodule Astrorunner do
  @moduledoc """
  Digital version of the boardgame *Astrorunner*
  """

  alias Phoenix.PubSub
  alias Astrorunner.Board

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

  def take_revealed_card(name: name, index: index, user: user) do
    Board.update(&fun_take_revealed_card(&1, &2), name: name, index: index, user: user)
  end

  def fun_get_global_decks(global) do
    global
    |> Map.get(:cards)
    |> Enum.reduce(%{}, fn {key, value}, res ->
      Map.put_new(res, key, value.revealed)
    end)
  end

  def fun_take_revealed_card(global, [name: name, index: index, user: user] = params) do
    dbg(params)
  end
end
