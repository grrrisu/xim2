defmodule Astrorunner do
  @moduledoc """
  Digital version of the boardgame *Astrorunner*
  """

  alias Astrorunner.Board

  def setup() do
    Board.global_setup()
  end

  def global_board() do
    Board.global_board()
  end

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
end
