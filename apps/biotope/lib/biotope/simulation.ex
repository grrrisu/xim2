defmodule Biotope.Simulation do
  alias Phoenix.PubSub

  alias Ximula.Simulator
  alias Ximula.Sim.Queue
  alias Ximula.Grid

  alias Biotope.Sim.{Vegetation, Animal}
  alias Biotope.Simulator.Task.Supervisor

  @simulations [
    Vegetation,
    Animal
  ]

  @simulations %{
    vegetation: Vegetation,
    herbivore: Animal
  }

  def sim(%Queue{} = queue, opts) do
    Enum.map(@simulations, &sim_simulation(&1, opts))
    |> aggregate_results(queue)
    |> notify_sum()
  end

  def sim_simulation({layer, simulation}, opts) do
    Simulator.benchmark(fn ->
      get_data(layer, opts[:data])
      |> sim_items(simulation, opts[:data])
      |> handle_success(layer, opts[:data])
      |> handle_failed(opts[:data])
      |> summarize(simulation)
      |> notify()
    end)
  end

  defp sim_items(items, Vegetation, data) do
    Simulator.sim(
      items,
      {Vegetation, :sim, []},
      fn {position, _v} -> position end,
      Supervisor
    )
  end

  defp sim_items(items, simulation, data) do
    Simulator.sim(
      items,
      {simulation, :sim, [data: data]},
      & &1.position,
      Supervisor
    )
  end

  def get_data(:vegetation, data) do
    Biotope.exclusive_get(:vegetation, data) |> Grid.positions_and_values()
  end

  def get_data(layer, data) do
    Biotope.exclusive_get(layer, data)
  end

  def set_data(fields, data) do
    Biotope.update(:vegetation, fields, data)
  end

  def handle_success(%{ok: fields} = results, _layer, data) do
    :ok = set_data(fields, data)
    results
  end

  def handle_failed(%{exit: failed} = results, _proxy) do
    Enum.each(failed, fn reason ->
      IO.puts("failed simulations: #{Exception.format_exit(reason)}")
    end)

    results
  end

  def summarize(%{ok: success, exit: failed}, simulation) do
    %{
      simulation: simulation,
      ok: Enum.map(success, fn {position, _v} -> position end),
      error:
        Enum.map(failed, fn {id, {exception, stacktrace}} ->
          {id, Exception.normalize(:exit, exception, stacktrace) |> Exception.message()}
        end)
    }
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

  def notify_sum(results) do
    # PubSub.broadcast(topic, queue_result) | GenStage.cast(stage, {:receive, queue_result})
    dbg(results)
  end

  def notify(%{error: _error, ok: ok, simulation: simulation} = result) do
    :ok =
      PubSub.broadcast(Xim2.PubSub, "Biotope:simulation", %{
        simulation: simulation,
        changed: ok
      })

    result
  end
end
