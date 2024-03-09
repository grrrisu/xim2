defmodule Sim.Monitor.Data do
  @moduledoc """
  the simulation dummy data
  """

  alias Phoenix.PubSub

  alias Ximula.AccessData
  alias Ximula.Simulator

  def create(server, size) do
    data = 0..(size - 1) |> Enum.reduce(%{}, &Map.put_new(&2, &1, %{value: 0}))
    :ok = AccessData.set(server, fn _data -> data end)
  end

  def created?(server) do
    AccessData.get(server, fn data -> !is_nil(data) end)
  end

  def get(server, key) do
    AccessData.get(server, &Map.get(&1, key))
  end

  def change(key, {:data, data}, {:timeout, timeout}) do
    value = AccessData.lock(key, data, fn data -> get_in(data, [key, :value]) end)

    timeout |> div(1000) |> Process.sleep()

    AccessData.update(key, data, fn data ->
      put_in(data, [key, :value], value + 1)
    end)

    {key, value}
  end

  def change(one, two), do: raise(inspect([one, two]))

  def run_queue(queue, timeout: timeout, tasks: tasks, data: data, supervisor: supervisor) do
    Simulator.benchmark(fn ->
      get_items(data)
      |> Simulator.sim({__MODULE__, :change, data: data, timeout: timeout}, supervisor,
        max_concurrency: tasks
      )

      # |> handle_success()
      # |> handle_failed()
      # |> summarize(simulation)
      # |> notify()
    end)
    |> aggregate_results(queue.name)
    |> notify_sum()
  end

  defp get_items(server) do
    size = AccessData.get(server, &Enum.count(&1))
    0..(size - 1)
  end

  defp aggregate_results({duration, %{exit: error, ok: ok}}, queue) do
    %{
      queue: queue,
      time: DateTime.utc_now(),
      duration: duration,
      ok: Enum.count(ok),
      errors: Enum.count(error)
    }
  end

  defp notify_sum(results) do
    PubSub.broadcast(Xim2.PubSub, "Monitor:data", {:queue_summary, results})
  end
end
