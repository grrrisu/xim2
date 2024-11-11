defmodule MyLiege.SimulationTest do
  use ExUnit.Case, async: true

  alias MyLiege.Simulation.Population, as: Simulation
  alias MyLiege.Population

  def round_population(
        %{
          working: %{gen_1: working_gen_1, gen_2: working_gen_2, gen_3: working_gen_3},
          poverty: %{gen_1: poverty_gen_1, gen_2: poverty_gen_2, gen_3: poverty_gen_3}
        } = change
      ) do
    %{
      change
      | working: %{
          gen_1: round(working_gen_1),
          gen_2: round(working_gen_2),
          gen_3: round(working_gen_3)
        },
        poverty: %{
          gen_1: round(poverty_gen_1),
          gen_2: round(poverty_gen_2),
          gen_3: round(poverty_gen_3)
        }
    }
  end

  describe "sim_population" do
    setup do
      %{
        data: %{
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
            }
          }
        }
      }
    end

    test "enough food", %{data: data} do
      # enough food for population after grow
      change = %{food: 107}

      population =
        Map.merge(data.population, %{birth_rate: 0.4, death_rate: 0.1, disease_rate: 0.2})

      data = Map.merge(data, %{population: population})

      {change, _data, _global} = Simulation.sim_population({change, data, %{}})

      change =
        Map.merge(change, %{
          food: round(change.food),
          population: round_population(change.population)
        })

      assert %{
               food: 20,
               population: %{
                 working: %{gen_1: 8, gen_2: 8, gen_3: 16},
                 poverty: %{gen_1: 9, gen_2: 7, gen_3: 0}
               }
             } = change
    end
  end

  describe "grow_population" do
    setup do
      %{
        change: %{
          working: %Population{
            gen_1: 10.0,
            gen_2: 10.0,
            gen_3: 10.0
          },
          poverty: %Population{
            gen_1: 10.0,
            gen_2: 10.0,
            gen_3: 10.0
          }
        }
      }
    end

    test "normal", %{change: change} do
      {{change, _log}, _data, _global} =
        Simulation.grow_population({{change, []}, %{birth_rate: 0.4}, %{}})

      change = round_population(change)

      assert %{
               working: %{gen_1: 12, gen_2: 10, gen_3: 13},
               poverty: %{gen_1: 16, gen_2: 10, gen_3: 13}
             } = change
    end
  end

  describe "shrink_population" do
    setup do
      %{
        change: %{
          working: %Population{
            gen_1: 10.0,
            gen_2: 10.0,
            gen_3: 10.0
          },
          poverty: %Population{
            gen_1: 10.0,
            gen_2: 10.0,
            gen_3: 10.0
          }
        }
      }
    end

    test "normal", %{change: change} do
      {{change, _log}, _data, _global} =
        Simulation.shrink_population({{change, []}, %{death_rate: 0.2, disease_rate: 0.1}, %{}})

      change = round_population(change)

      assert %{
               working: %{gen_1: 9, gen_2: 9, gen_3: 7},
               poverty: %{gen_1: 8, gen_2: 9, gen_3: 5}
             } = change
    end
  end

  describe "feed_population" do
    setup do
      %{
        change: %{
          food: 0.0,
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
          }
        }
      }
    end

    test "feed social stratum" do
      population =
        Simulation.feed_social_stratum(
          %Population{gen_1: 2, gen_2: 4, gen_3: 8, needed_food: {1, 2, 3}},
          (2 + 8 + 24) / 2
        )

      assert %{gen_1: 1.0, gen_2: 2.0, gen_3: 4.0} = population
    end

    test "no food", %{change: change} do
      change = Map.put(change, :food, 0)
      {{change, _log}, _data, _global} = Simulation.feed_population({{change, []}, %{}, %{}})
      change = round_population(change)

      assert %{
               food: +0.0,
               working: %{gen_1: 0, gen_2: 0, gen_3: 0},
               poverty: %{gen_1: 0, gen_2: 0, gen_3: 0}
             } = change
    end

    test "enough for working", %{change: change} do
      change = Map.put(change, :food, 10 + 20 + 30)
      {{change, _log}, _data, _global} = Simulation.feed_population({{change, []}, %{}, %{}})
      change = round_population(change)

      assert %{
               food: +0.0,
               working: %{gen_1: 9, gen_2: 9, gen_3: 8},
               poverty: %{gen_1: 3, gen_2: 3, gen_3: 4}
             } = change
    end

    test "only half for working", %{change: change} do
      change = Map.put(change, :food, (10 + 20 + 30) / 2)
      {{change, _log}, _data, _global} = Simulation.feed_population({{change, []}, %{}, %{}})
      change = round_population(change)

      assert %{
               food: +0.0,
               working: %{gen_1: 4, gen_2: 4, gen_3: 2},
               poverty: %{gen_1: 1, gen_2: 1, gen_3: 7}
             } = change
    end

    test "enough for poverty", %{change: change} do
      change = Map.put(change, :food, 10 + 20 + 30 + 10 + 10 + 10)
      {{change, _log}, _data, _global} = Simulation.feed_population({{change, []}, %{}, %{}})
      change = round_population(change)

      assert %{
               food: +0.0,
               working: %{gen_1: 10, gen_2: 10, gen_3: 10},
               poverty: %{gen_1: 10, gen_2: 10, gen_3: 10}
             } = change
    end

    test "reduce poverty", %{change: change} do
      change = Map.put(change, :food, 10 + 20 + 30 + 10 + 10 + 10 + 8)
      {{change, _log}, _data, _global} = Simulation.feed_population({{change, []}, %{}, %{}})
      change = round_population(change)

      assert %{
               food: +0.0,
               working: %{gen_1: 10, gen_2: 10, gen_3: 14},
               poverty: %{gen_1: 10, gen_2: 10, gen_3: 6}
             } = change
    end

    test "remaining food", %{change: change} do
      change = Map.put(change, :food, 10 + 20 + 30 + 10 + 10 + 10 + 50)
      {{change, _log}, _data, _global} = Simulation.feed_population({{change, []}, %{}, %{}})
      change = round_population(change)

      assert %{
               food: 30.0,
               working: %{gen_1: 10, gen_2: 10, gen_3: 20},
               poverty: %{gen_1: 10, gen_2: 10, gen_3: 0}
             } = change
    end
  end
end
