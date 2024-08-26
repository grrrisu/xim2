defmodule Astrorunner.Board do
  @moduledoc """
  State of the game. Global and player boards
  """

  use Agent

  alias Astrorunner.Card

  @global_board %{cards: %{pilots: [], level_1: [], level_2: []}}
  # @user_board %{mission_control: [], crew: [], research: []}

  def start_link(opts \\ []) do
    Agent.start_link(fn -> %{global: @global_board, users: %{}} end,
      name: opts[:name] || __MODULE__
    )
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

  def handle_global_setup() do
    %{cards: %{pilots: [], level_1: Card.build(:lab_assistent, 4), level_2: []}}
  end
end
