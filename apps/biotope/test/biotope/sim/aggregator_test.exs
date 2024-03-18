defmodule Biotope.Sim.AggregatorTest do
  use ExUnit.Case, async: true

  alias Biotope.Sim.{Vegetation, Animal}
  alias Biotope.Aggregator

  setup do
    vegetation_results =
      [
        %{
          change: %{vegetation: %{size: 306.0, position: {0, 0}}},
          origin: %{vegetation: %Vegetation{size: 300.0}}
        },
        %{
          change: %{vegetation: %{size: 5999.9, position: {0, 1}}},
          origin: %{vegetation: %Vegetation{size: 5999.8}}
        },
        %{
          change: %{vegetation: %{size: 5900.6, position: {0, 2}}},
          origin: %{vegetation: %Vegetation{size: 5900.4}}
        },
        %{
          change: %{vegetation: %{size: 4200.0, position: {0, 3}}},
          origin: %{vegetation: %Vegetation{size: 4000.0}}
        }
      ]

    herbivore_results =
      [
        %{
          change: %{
            vegetation: %{size: 4000.0, position: {0, 3}},
            herbivore: %{size: 550.0, position: {0, 3}}
          },
          origin: %{
            vegetation: %Vegetation{size: 4200.0},
            herbivore: %Animal.Herbivore{size: 500.0, position: {0, 3}}
          }
        }
      ]

    %{
      summary:
        Aggregator.aggregate_simulations(
          [
            %{ok: vegetation_results, error: [], simulation: :vegetation},
            %{ok: herbivore_results, error: [], simulation: :herbivore}
          ],
          nil
        )
    }
  end

  test "vegetation grows", %{summary: summary} do
    change = Enum.find(summary.vegetation, &(&1.position == {0, 0}))
    assert 306 == change.size
  end

  test "vegetation stops growing", %{summary: summary} do
    change = Enum.find(summary.vegetation, &(&1.position == {0, 1}))
    assert nil == change
  end

  test "vegetation slowly grows", %{summary: summary} do
    change = Enum.find(summary.vegetation, &(&1.position == {0, 2}))
    assert 5901 == change.size
  end

  test "herbivore consumes grown vegetation", %{summary: summary} do
    change = Enum.find(summary.vegetation, &(&1.position == {0, 3}))
    assert nil == change
    change = Enum.find(summary.herbivore, &(&1.position == {0, 3}))
    assert 550 == change.size
  end
end
