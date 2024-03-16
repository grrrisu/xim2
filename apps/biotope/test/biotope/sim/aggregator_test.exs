defmodule Biotope.Sim.AggregatorTest do
  use ExUnit.Case, async: true

  alias Biotope.Sim.Vegetation
  alias Biotope.Aggregator

  setup do
    summary = %{vegetation: %{}, herbivore: %{}, predator: %{}}

    results =
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
        },
        %{
          change: %{vegetation: %{size: 4000.0, position: {0, 3}}},
          origin: %{vegetation: %Vegetation{size: 4200.0}}
        }
      ]

    %{
      summary: Enum.reduce(results, summary, &Aggregator.aggregate(&1, &2))
    }
  end

  test "vegetation grows", %{summary: summary} do
    assert {change, origin} = get_in(summary, [:vegetation, {0, 0}])
    assert 306 == change.size
    assert 300 == origin.size
  end

  test "vegetation stops growing", %{summary: summary} do
    assert nil == get_in(summary, [:vegetation, {0, 1}])
  end

  test "vegetation slowly grows", %{summary: summary} do
    assert {change, origin} = get_in(summary, [:vegetation, {0, 2}])
    assert 5901 == change.size
    assert 5900.4 == origin.size
  end

  test "herbivore consume vegetation grow", %{summary: summary} do
    assert nil == get_in(summary, [:vegetation, {0, 3}])
  end
end
