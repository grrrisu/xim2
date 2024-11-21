defmodule MyLiege.Simulation.FactoryTest do
  use ExUnit.Case, async: true

  alias MyLiege.Simulation.Factory, as: Simulation

  describe "sim factory" do
    setup do
      %{
        data: %{
          factories: [
            %{type: :farm, workers: [:normal], work_done: 3}
          ]
        },
        global: %{
          blueprints: %{
            farm: %{
              input: [],
              output: %{food: 400},
              production_time: 4,
              min_workers: [:normal],
              max_workers: [:green, :normal]
            }
          }
        }
      }
    end

    test "enough resources", %{data: data, global: global} do
      {change, _data, _global} = Simulation.sim_factory({{%{}, [], nil}, data, global})

      assert change == %{storage: %{food: 400}, factories: [%{work_done: 0}]}
    end
  end

  describe "factory production" do
    setup do
      %{
        blueprint: %{
          input: [],
          output: %{food: 400},
          production_time: 4,
          min_workers: [:normal],
          max_workers: [:green, :normal]
        }
      }
    end

    test "start working", %{blueprint: blueprint} do
      factory = %{type: :farm, workers: [:normal], work_done: 0}
      {output, factory} = Simulation.sim_production(factory, blueprint)
      assert [] == output
      assert %{work_done: 1} = factory
    end

    test "work done", %{blueprint: blueprint} do
      factory = %{type: :farm, workers: [:normal], work_done: 3}
      {output, factory} = Simulation.sim_production(factory, blueprint)
      assert %{food: 400} == output
      assert %{work_done: 0} = factory
    end

    test "working with two workers", %{blueprint: blueprint} do
      factory = %{type: :farm, workers: [:normal, :normal], work_done: 0}
      {output, factory} = Simulation.sim_production(factory, blueprint)
      assert [] == output
      assert %{work_done: 2} = factory
    end

    test "no workers", %{blueprint: blueprint} do
      factory = %{type: :farm, workers: [], work_done: 3}
      {output, factory} = Simulation.sim_production(factory, blueprint)
      assert [] == output
      assert %{work_done: 3} = factory
    end
  end
end
