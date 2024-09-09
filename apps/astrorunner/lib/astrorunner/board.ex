defmodule Astrorunner.Board do
  @moduledoc """
  State of the game. Global and player boards
  """

  use Agent

  alias Astrorunner.{Card, Deck}

  @initial_state %{global: %{cards: nil}, players: %{}}

  @level_1_cards %{
    lab_assistent: 4,
    tinkerer: 4,
    mathematician: 4,
    racing_car_mechanic: 4,
    trouble_shooter: 4,
    tester: 4,
    data_analyst: 4
  }

  @level_2_cards %{}

  @pilot_cards %{
    stuntmen: 5,
    line_pilot: 5,
    test_pilot: 5
  }

  def start_link(opts \\ []) do
    Agent.start_link(fn -> @initial_state end, name: opts[:name])
  end

  def clear(server \\ __MODULE__) do
    Agent.update(server, fn _ -> @initial_state end)
  end

  def get(func \\ & &1, server \\ __MODULE__) do
    Agent.get(server, func)
  end

  def get_global(func, server \\ __MODULE__) do
    Agent.get(server, fn %{global: global} -> handle_get_global(func, global) end)
  end

  def update_global_board(func, server \\ __MODULE__, params) do
    Agent.get_and_update(server, fn %{global: global} = state ->
      {result, global} = handle_update_global(func, global, params)
      {result, %{state | global: global}}
    end)
  end

  def global_board(server \\ __MODULE__) do
    Agent.get(server, fn %{global: global} -> global end)
  end

  def player_board(player, server \\ __MODULE__) do
    Agent.get(server, fn %{players: players} -> Map.get(players, player) end)
  end

  def setup(players, server \\ __MODULE__) do
    Agent.update(server, fn state ->
      state
      |> Map.put(:global, handle_global_setup())
      |> Map.put(:players, handle_players_setup(players))
    end)
  end

  def get_deck_and_player_tableau(name, player, server \\ __MODULE__) do
    Agent.get(server, fn state ->
      {get_in(state, [:global, :cards, name]), get_in(state, [:players, player])}
    end)
  end

  def put_deck_and_player_tableau({name, deck}, {player, tableau}, server \\ __MODULE__) do
    Agent.get_and_update(server, fn state ->
      {
        {deck.revealed, tableau},
        state |> put_in([:global, :cards, name], deck) |> put_in([:players, player], tableau)
      }
    end)
  end

  def handle_get_global(func, global) do
    func.(global)
  end

  def handle_update_global(func, global, params) do
    func.(global, params)
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

  def handle_players_setup(players) do
    Enum.reduce(players, %{}, fn player, players ->
      Map.put_new(players, player, %{
        crew: [],
        mission: [],
        rnd: [],
        money: 3,
        xp: %{chemistry: 0, engineering: 0, math: 0},
        research: %{radar: 0, survive: 0, navigation: 0, structure: 0, engine: 0},
        gear: %{radar: 1, survive: 1, navigation: 1, structure: 1, engine: 1}
      })
    end)
  end

  defp build_cards(cards) do
    cards
    |> Enum.reduce([], fn {name, amount}, res -> res ++ Card.build(name, amount) end)
    |> Deck.setup()
    |> Deck.reveal(4)
  end

  def tableau_place(card) do
    case card.type do
      :pilot -> :crew
      :research -> :rnd
      :engineer -> :rnd
      :mission -> :mission
    end
  end
end
