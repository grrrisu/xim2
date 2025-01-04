defmodule MyLiege.Simulation.PopulationTest do
  use ExUnit.Case, async: true

  alias MyLiege.Simulation.Population, as: Simulation
  alias MyLiege.Population.Generation

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
end
