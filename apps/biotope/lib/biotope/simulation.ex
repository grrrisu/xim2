defmodule Biotope.Simulation do
  alias Phoenix.PubSub

  alias Ximula.Simulator
  alias Ximula.Sim.Queue

  alias Biotope.Data
  alias Biotope.Sim.{Vegetation, Animal}
  alias Biotope.Simulator.Task.Supervisor

  @simulations %{
    vegetation: Vegetation
    # herbivore: Animal
  }

  def sim(%Queue{} = queue, opts) do
    Enum.map(@simulations, &sim_simulation(&1, opts))
    |> aggregate_results(queue)
    |> notify_queue_summary()
  end

  def sim_simulation({sim_key, simulation}, opts) do
    Simulator.benchmark(fn ->
      get_data(sim_key, opts[:data])
      |> sim_items(simulation, opts[:data])
      |> handle_success(sim_key)
      |> handle_failed(sim_key)
      |> summarize(sim_key)
      |> notify_simulation_summary()
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

  # def get_data(layer, data) do
  #   # Biotope.exclusive_get(layer, data)
  # end

  def handle_success(%{ok: fields} = results, sim_key) do
    :ok = notify(:simulation_results, {sim_key, fields})
    results
  end

  def handle_failed(%{exit: failed} = results, sim_key) do
    :ok = notify(:simulation_errors, {sim_key, failed})
    results
  end

  def summarize(%{ok: success, exit: failed}, simulation) do
    %{
      simulation: simulation,
      ok: Enum.map(success, fn {position, _v} -> position end),
      error:
        Enum.map(failed, fn {id, {exception, stacktrace}} ->
          {id, Exception.normalize(:exit, exception, stacktrace)}
        end)
    }
  end

  def notify_simulation_summary(result) do
    :ok = notify(:simulation_summary, result)
    result
  end

  # [{1097, %{error: [], ok: [], simulation: Sim.Vegetation}}]
  def aggregate_results(results, queue) do
    %{
      queue: queue.name,
      results:
        Enum.map(results, fn {time, %{error: error, ok: ok, simulation: simulation}} ->
          %{simulation: simulation, time: time, errors: Enum.count(error), ok: Enum.count(ok)}
        end)
    }
  end

  def notify_queue_summary(results) do
    :ok = notify(:queue_summary, results)
    results
  end

  defp notify(topic, payload) do
    :ok =
      PubSub.broadcast(Xim2.PubSub, "Simulation:biotope", {:simulation_biotope, topic, payload})
  end
end
