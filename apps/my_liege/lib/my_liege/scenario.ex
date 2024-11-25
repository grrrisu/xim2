defmodule MyLiege.Scenario do
  alias MyLiege.Population

  @population %{
    data: %{
      storage: %{food: 94},
      population: %{
        working: %Population{
          gen_1: 10.0,
          gen_2: 10.0,
          gen_3: 10.0,
          needed_food: {1, 2, 3},
          spending_power: 3
        },
        poverty: %Population{
          gen_1: 10.0,
          gen_2: 10.0,
          gen_3: 10.0,
          needed_food: {1, 1, 1},
          spending_power: 1
        },
        birth_rate: 0.4,
        death_rate: 0.05,
        disease_rate: 0.08
      }
    },
    global: %{}
  }

  @factory %{
    data: %{
      factories: [
        %{type: :farm, workers: [:normal], work_done: 3}
      ]
    },
    global: %{
      blueprints: %{
        farm: %{
          input: %{},
          output: %{food: 400},
          production_time: 4,
          min_workers: [:normal],
          max_workers: [:green, :normal]
        }
      }
    }
  }

  @scenarios %{
    population: @population,
    factory: @factory
  }

  def get(key) do
    Map.fetch!(@scenarios, key)
  end
end
