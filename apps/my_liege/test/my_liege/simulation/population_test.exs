defmodule MyLiege.Simulation.PopulationTest do
  use ExUnit.Case, async: true

  alias MyLiege.Simulation.Population, as: Simulation
  alias MyLiege.Population
  alias MyLiege.Population.Generation

  test "sim population" do
    data = %{
      population: %{
        working: %Population{
          gen_1: %Generation{people: 20},
          gen_2: %Generation{people: 20},
          gen_3: %Generation{people: 40}
        },
        poverty: %Population{
          gen_1: %Generation{people: 30},
          gen_2: %Generation{people: 30},
          gen_3: %Generation{people: 60}
        }
      }
    }

    {change, _, _} = Simulation.sim_population({%{}, data, %{}})

    assert %{working: %Population{}, poverty: %Population{}} = Map.get(change, :population)
  end

  test "population grow" do
    population = %{
      gen_1: %Generation{people: 20, grow_rem: 20},
      gen_2: %Generation{people: 20, grow_rem: 20},
      gen_3: %Generation{people: 40, grow_rem: 40}
    }

    population = Simulation.grow(population)

    # gen_3 growed by 1 and passed it to gen_1, which itself transfered 1 to gen_2
    assert %{
             gen_1: %Generation{people: 20, grow_rem: 0},
             gen_2: %Generation{people: 21, grow_rem: 40},
             gen_3: %Generation{people: 40, grow_rem: 20}
           } = population
  end

  test "population shrink" do
    population = %{
      gen_1: %Generation{people: 20, disease_rem: 100},
      gen_2: %Generation{people: 20, disease_rem: 100},
      gen_3: %Generation{people: 40, disease_rem: 200, age_rem: 200}
    }

    population = Simulation.shrink(population)

    # after half a year gen_1 and gen_3 loose 1 each to diseases
    assert %{
             gen_1: %Generation{people: 19, disease_rem: 0},
             gen_2: %Generation{people: 20, disease_rem: 120},
             gen_3: %Generation{people: 39, disease_rem: 0, age_rem: 240}
           } = population
  end
end
