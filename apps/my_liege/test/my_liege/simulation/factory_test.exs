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
              input: %{},
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
      {change, _data, _global} =
        Simulation.sim_factory({%{storage: %{food: 50}}, data, global})

      assert %{storage: %{food: 450}, factories: [%{work_done: 0}]} = change
    end
  end

  describe "aggregate storage" do
    test "add new types" do
      storage = Simulation.aggregate_storage(%{food: 10}, %{food: 5, wood: 5})
      assert %{food: 15, wood: 5} = storage
    end
  end

  describe "farm production" do
    setup do
      %{
        blueprint: %{
          input: %{},
          output: %{food: 400},
          production_time: 4,
          min_workers: [:normal],
          max_workers: [:green, :normal]
        }
      }
    end

    test "start working", %{blueprint: blueprint} do
      factory = %{type: :farm, workers: [:normal], work_done: 0}
      {output, factory} = Simulation.sim_production(factory, blueprint, %{})
      assert %{} == output
      assert %{work_done: 1} = factory
    end

    test "work done", %{blueprint: blueprint} do
      factory = %{type: :farm, workers: [:normal], work_done: 3}
      {output, factory} = Simulation.sim_production(factory, blueprint, %{})
      assert %{food: 400} == output
      assert %{work_done: 0} = factory
    end

    test "working with two workers", %{blueprint: blueprint} do
      factory = %{type: :farm, workers: [:normal, :normal], work_done: 0}
      {output, factory} = Simulation.sim_production(factory, blueprint, %{})
      assert %{} == output
      assert %{work_done: 2} = factory
    end

    test "no workers", %{blueprint: blueprint} do
      factory = %{type: :farm, workers: [], work_done: 3}
      {output, factory} = Simulation.sim_production(factory, blueprint, %{})
      assert %{} == output
      assert %{work_done: 3} = factory
    end
  end

  describe "factory production" do
    setup do
      %{
        blueprint: %{
          input: %{coal: 5, iron: 2},
          output: %{tool: 1},
          production_time: 4,
          min_workers: [:normal],
          max_workers: [:blue, :normal]
        }
      }
    end

    test "no enough input available", %{blueprint: blueprint} do
      factory = %{type: :forge, workers: [:normal], work_done: 3}
      storage = %{coal: 3, iron: 5}
      {output, factory} = Simulation.sim_production(factory, blueprint, storage)
      assert %{} = output
      assert %{work_done: 3} = factory
    end

    test "enough input", %{blueprint: blueprint} do
      factory = %{type: :forge, workers: [:normal], work_done: 3}
      storage = %{coal: 10, iron: 5}
      {output, factory} = Simulation.sim_production(factory, blueprint, storage)
      assert %{coal: -5, iron: -2, tool: 1} = output
      assert %{work_done: 0} = factory
    end
  end
end
