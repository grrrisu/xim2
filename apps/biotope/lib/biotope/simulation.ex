defmodule Biotope.Simulation do
  alias Phoenix.PubSub

  alias Ximula.Sim.TaskRunner, as: Simulator

  alias Biotope.{Aggregator, Data}
  alias Biotope.Sim.{Vegetation, Animal}
  alias Biotope.Simulator.Task.Supervisor

  @simulations %{
    vegetation: Vegetation,
    herbivore: Animal.Herbivore,
    predator: Animal.Predator
  }

  def sim(opts) do
    Enum.map(@simulations, &sim_simulation(&1, opts))
    |> Enum.map(fn {time, results} -> Map.put_new(results, :time, time) end)
    |> aggregate_simulations()
    |> count_results()
    |> notify_queue_summary()
  end

  def sim_simulation({sim_key, simulation}, opts) do
    Simulator.benchmark(fn ->
      get_data(sim_key, opts[:data])
      |> sim_items(simulation, opts[:data])
      |> handle_failed()
      |> handle_results(sim_key)
    end)
  end

  def sim_items(items, simulation, data) do
    Simulator.sim(
      items,
      {simulation, :sim, [[data: data]]},
      Supervisor
    )
  end

  def get_data(:vegetation, data) do
    Data.get_grid_dimensions(data)
    |> Data.get_grid_positions()
  end

  def get_data(layer, data) do
    Data.get_layer_positions(layer, data)
  end

  def handle_failed(%{exit: failed} = results) do
    failed =
      Enum.map(failed, fn {id, {exception, stacktrace}} ->
        {id, Exception.normalize(:error, exception, stacktrace) |> Exception.message()}
      end)

    if Enum.any?(failed), do: notify(:simulation_errors, failed)
    Map.put(results, :exit, failed)
  end

  def handle_results(%{ok: success, exit: failed}, simulation) do
    %{
      simulation: simulation,
      ok: success,
      error: failed
    }
  end

  def aggregate_simulations(results) do
    summary = Aggregator.aggregate_simulations(results)
    :ok = notify(:entities_changed, summary)
    results
  end

  # [{1097, %{error: [], ok: [], simulation: Sim.Vegetation}}]
  def count_results(results) do
    %{
      queue: :normal,
      results:
        Enum.reduce(results, %{}, fn %{error: error, ok: ok, simulation: simulation, time: time},
                                     sum ->
          Map.put(sum, simulation, %{time: time, error: Enum.count(error), ok: Enum.count(ok)})
        end)
    }
  end

  def notify_queue_summary(results) do
    :ok = notify(:queue_summary, results)
    results
  end

  defp notify(topic, payload) do
    :ok =
      PubSub.broadcast(Xim2.PubSub, "simulation:biotope", {:simulation_biotope, topic, payload})
  end
end
