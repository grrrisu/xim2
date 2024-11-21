defmodule MyLiege.Simulation.Factory do
  @moduledoc """
  simulates the production of the factories
  """

  # alias MyLiege.Simulation

  def sim_factory({change, data, global}) do
    # {{change, [], nil}, data, global}
    change =
      Enum.map(data.factories, fn factory ->
        blueprint = get_in(global, [:blueprints, factory.type])
        sim_production(factory, blueprint)
      end)
      |> Enum.reduce({change.storage, []}, fn {output, factory}, {storage, factories} ->
        %{storage: aggregate_storage(storage, output), factories: [factory | factories]}
      end)
      |> then(fn new_changes ->
        Map.merge(change, new_changes)
      end)

    {change, data, global}
  end

  def aggregate_storage(storage, changes) do
    Enum.reduce(changes, storage, fn {key, value}, storage ->
      case Map.get(storage, key) do
        nil -> Map.put_new(storage, key, value)
        before -> Map.put(storage, key, before + value)
      end
    end)
  end

  def sim_production(%{workers: []} = factory, _blueprint) do
    {[], factory}
  end

  def sim_production(
        %{workers: [_ | _] = workers, work_done: work_done} = factory,
        %{production_time: production_time} = blueprint
      ) do
    case work_done + calculate_work(workers) do
      work_done when production_time <= work_done -> {blueprint.output, %{factory | work_done: 0}}
      work_done -> {[], %{factory | work_done: work_done}}
    end
  end

  def calculate_work(workers), do: Enum.count(workers)
end
