defmodule MyLiege.SimulationTest do
  use ExUnit.Case, async: true

  alias MyLiege.Simulation

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

  describe "feed_population" do
    setup do
      %{
        change: %{
          food: 0.0,
          working: %{gen_1: 10.0, gen_2: 10.0, gen_3: 10.0},
          poverty: %{gen_1: 10.0, gen_2: 10.0, gen_3: 10.0}
        }
      }
    end

    test "feed social stratum" do
      population =
        Simulation.feed_social_stratum(
          %{gen_1: 2, gen_2: 4, gen_3: 8},
          (2 + 8 + 24) / 2,
          {1, 2, 3}
        )

      assert %{gen_1: 1, gen_2: 2, gen_3: 4} == population
    end

    test "no food", %{change: change} do
      change = Map.put(change, :food, 0)
      {change, _data, _global} = Simulation.feed_population({change, %{}, %{}})
      change = round_population(change)

      assert %{
               food: +0.0,
               working: %{gen_1: 0, gen_2: 0, gen_3: 0},
               poverty: %{gen_1: 0, gen_2: 0, gen_3: 0}
             } = change
    end

    test "enough for working", %{change: change} do
      change = Map.put(change, :food, 10 + 20 + 30)
      {change, _data, _global} = Simulation.feed_population({change, %{}, %{}})
      change = round_population(change)

      assert %{
               food: +0.0,
               working: %{gen_1: 9, gen_2: 9, gen_3: 9},
               poverty: %{gen_1: 3, gen_2: 3, gen_3: 3}
             } = change
    end

    test "only half for working", %{change: change} do
      change = Map.put(change, :food, (10 + 20 + 30) / 2)
      {change, _data, _global} = Simulation.feed_population({change, %{}, %{}})
      change = round_population(change)

      assert %{
               food: +0.0,
               working: %{gen_1: 4, gen_2: 4, gen_3: 4},
               poverty: %{gen_1: 1, gen_2: 1, gen_3: 1}
             } = change
    end

    test "enough for poverty", %{change: change} do
      change = Map.put(change, :food, 10 + 20 + 30 + 10 + 10 + 10)
      {change, _data, _global} = Simulation.feed_population({change, %{}, %{}})
      change = round_population(change)

      assert %{
               food: +0.0,
               working: %{gen_1: 10, gen_2: 10, gen_3: 10},
               poverty: %{gen_1: 10, gen_2: 10, gen_3: 10}
             } = change
    end

    test "reduce poverty", %{change: change} do
      change = Map.put(change, :food, 10 + 20 + 30 + 10 + 10 + 10 + 8)
      {change, _data, _global} = Simulation.feed_population({change, %{}, %{}})
      change = round_population(change)

      assert %{
               food: +0.0,
               working: %{gen_1: 10, gen_2: 10, gen_3: 14},
               poverty: %{gen_1: 10, gen_2: 10, gen_3: 6}
             } = change
    end

    test "remaining food", %{change: change} do
      change = Map.put(change, :food, 10 + 20 + 30 + 10 + 10 + 10 + 50)
      {change, _data, _global} = Simulation.feed_population({change, %{}, %{}})
      change = round_population(change)

      assert %{
               food: 30.0,
               working: %{gen_1: 10, gen_2: 10, gen_3: 20},
               poverty: %{gen_1: 10, gen_2: 10, gen_3: 0}
             } = change
    end
  end
end
