defmodule MyLiege.Simulation do
  @moduledoc """
  data = %{
    working: %{
      generation_1: 10,
      generation_2: 10,
      generation_3: 10,
      spending_power: 3
      birth_rate: 0.1
    }
  }
  """
  alias Phoenix.PubSub

  alias MyLiege.Simulation.Population

  def sim({data, global}) do
    # gather amount of workers in factories for sim_population
    # if working population after sim_population is smaller than the amount of factory workers, we need to remove dead workers from the factories
    # if working (and maybe also poverty) <= 0 -> GAME over no population
    {%{}, data, global}
    |> harvest()
    |> Population.sim_population()
    |> apply_changes()

    # |> handle_dead_workers()
  end

  def apply_changes({change, %{population: population, storage: _storage} = data, _global}) do
    # maybe notifing
    # Map.merge(storage, %{food: food})
    %{
      data
      | population: %{
          population
          | working: change.population.working,
            poverty: change.population.poverty
        }
    }
  end

  def harvest({change, data, global}) do
    food = Map.get(data.storage, :food, 0)
    {Map.merge(change, %{food: food}), data, global}
  end

  def handle_dead_workers(_population_result, _data) do
    # if idle population after sim_population is negative, we need to remove poeple from the factories
    # if working + (negative) idle < 0 -> GAME over no population
  end

  def notify(event) do
    PubSub.broadcast(Xim2Web.PubSub, "my_liege", event)
  end
end
