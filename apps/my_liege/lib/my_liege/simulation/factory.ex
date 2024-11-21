defmodule MyLiege.Simulation.Factory do
  @moduledoc """
  simulates the production of the factories
  """

  # alias MyLiege.Simulation

  def sim_factory({change, data, global}) do
    # change = Map.merge(change, %{factories: data.factories})

    Enum.map(data.factories, fn factory ->
      blueprint = get_in(global, [:blueprints, factory.type])
      sim_production(factory, blueprint)
    end)

    # Enum.reduce outputs produced
    # put them in the storage

    {change, data, global}
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
