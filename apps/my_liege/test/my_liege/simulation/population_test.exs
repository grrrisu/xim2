defmodule MyLiege.Simulation.PopulationTest do
  use ExUnit.Case, async: true

  alias MyLiege.Simulation.Population, as: Simulation

  test "population grow" do
    population = %{
      gen_1: %{people: 20, work_done: 20},
      gen_2: %{people: 20, work_done: 20},
      gen_3: %{people: 40, work_done: 40}
    }

    population = Simulation.grow(population)

    # gen_3 growed by 1 and passed it to gen_1, which itself transfered 1 to gen_2
    assert %{
             gen_1: %{people: 20, work_done: 0},
             gen_2: %{people: 21, work_done: 40},
             gen_3: %{people: 40, work_done: 20}
           } = population
  end
end
