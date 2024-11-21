defmodule MyLiege.Simulation.Factory do
  @moduledoc """
  simulates the production of the factories
  """

  # alias MyLiege.Simulation

  def sim_factory({change, data, global}) do
    # {{change, [], nil}, data, global}
    change =
      Enum.reduce(data.factories, {change.storage, []}, fn factory, {storage, factories} ->
        blueprint = get_in(global, [:blueprints, factory.type])
        {output, factory} = sim_production(factory, blueprint, storage)
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

  def sim_production(%{workers: []} = factory, _blueprint, _storage) do
    {%{}, factory}
  end

  def sim_production(
        %{workers: [_ | _] = workers, work_done: work_done} = factory,
        %{production_time: production_time, input: input} = blueprint,
        storage
      ) do
    with true <- input_available?(storage, input),
         more_work when production_time <= more_work <-
           work_done + calculate_work(workers) do
      {produce_output(blueprint), %{factory | work_done: 0}}
    else
      false -> {%{}, %{factory | work_done: work_done}}
      more_work -> {%{}, %{factory | work_done: more_work}}
    end
  end

  def input_available?(storage, input) do
    Enum.all?(input, fn {key, value} -> Map.get(storage, key, 0) >= value end)
  end

  def calculate_work(workers), do: Enum.count(workers)

  def produce_output(%{input: input, output: output}) when map_size(input) == 0, do: output

  def produce_output(%{input: input, output: output}) do
    Enum.reduce(input, output, fn {key, value}, output ->
      Map.put(output, key, -value)
    end)
  end
end
