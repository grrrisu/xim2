defmodule Astrorunner.Board do
  @moduledoc """
  State of the game. Global and player boards
  """

  use Agent

  alias Astrorunner.{Card, Deck}

  @global_board %{cards: nil}
  # @user_board %{mission_control: [], crew: [], research: []}

  @level_1_cards %{
    lab_assistent: 4,
    tinkerer: 4
  }

  @level_2_cards %{}

  @pilot_cards %{
    stuntmen: 5,
    line_pilot: 5,
    test_pilot: 5
  }

  def start_link(opts \\ []) do
    Agent.start_link(fn -> %{global: @global_board, users: %{}} end,
      name: opts[:name] || __MODULE__
    )
  end

  def get_global(func, server \\ __MODULE__) do
    Agent.get(server, fn %{global: global} -> handle_get_global(func, global) end)
  end

  def global_board(server \\ __MODULE__) do
    Agent.get(server, fn %{global: global} -> global end)
  end

  def user_board(user, server \\ __MODULE__) do
    Agent.get(server, fn %{users: users} -> Map.get(users, user) end)
  end

  def global_setup(server \\ __MODULE__) do
    Agent.update(server, fn state -> Map.put(state, :global, handle_global_setup()) end)
  end

  def handle_get_global(func, global) do
    func.(global)
  end

  def handle_global_setup() do
    %{
      cards: %{
        pilots: build_cards(@pilot_cards),
        level_1: build_cards(@level_1_cards),
        level_2: build_cards(@level_2_cards)
      }
    }
  end

  defp build_cards(cards) do
    cards
    |> Enum.reduce([], fn {name, amount}, res -> res ++ Card.build(name, amount) end)
    |> Deck.setup()
    |> Deck.reveal(4)
  end
end
