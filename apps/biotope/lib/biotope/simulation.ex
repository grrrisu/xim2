defmodule Biotope.Simulation do
  alias Phoenix.PubSub

  alias Ximula.Simulator
  alias Ximula.Sim.Queue
  alias Ximula.Grid

  alias Biotope.Sim.Vegetation
  alias Biotope.Simulator.Task.Supervisor

  @simulations [
    Vegetation
  ]

  def sim(%Queue{} = queue, opts) do
    Enum.map(@simulations, &sim_simulation(&1, opts))
    |> aggregate_results(queue)
    |> notify_sum()
  end

  def sim_simulation(simulation, opts) do
    Simulator.benchmark(fn ->
      get_data(opts[:data])
      |> Simulator.sim({simulation, :sim, []}, Supervisor)
      |> handle_success(opts[:data])
      |> handle_failed(opts[:data])
      |> summarize(simulation)
      |> notify()
    end)
  end

  def get_data(data) do
    Biotope.exclusive_get(data) |> Grid.positions_and_values()
  end

  def set_data(fields, data) do
    Biotope.update(fields, data)
  end

  def handle_success(%{ok: fields} = results, data) do
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
