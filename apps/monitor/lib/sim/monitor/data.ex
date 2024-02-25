defmodule Sim.Monitor.Data do
  @moduledoc """
  the simulation dummy data
  """

  alias Ximula.AccessData
  alias Ximula.Simulator

  def create(server, size) do
    :ok = AccessData.lock(:all, server)
    data = 0..(size - 1) |> Enum.reduce(%{}, &Map.put_new(&2, &1, %{value: 0}))
    AccessData.update(:all, data, server, fn _data, _key, _value -> data end)
  end

  def created?(server) do
    AccessData.get_by(server, fn data -> !is_nil(data) end)
  end

  def get(server, key) do
    AccessData.get_by(server, &Map.get(&1, key))
  end

  def change(key, {:data, data}) do
    value = AccessData.lock(key, data, fn data, key -> get_in(data, [key, :value]) end)

    Process.sleep(50)

    AccessData.update(key, value, data, fn data, key, value ->
      put_in(data, [key, :value], value + 1)
    end)

    {key, value}
  end

  def change(one, two), do: raise(inspect([one, two]))

  def run_queue(queue, data: data, supervisor: supervisor) do
    Simulator.benchmark(fn ->
      get_items(data)
      |> Simulator.sim({__MODULE__, :change, data: data}, & &1, supervisor)

      # |> handle_success()
      # |> handle_failed()
      # |> summarize(simulation)
      # |> notify()
    end)
    |> aggregate_results(queue.name)
    |> notify_sum()
  end

  defp get_items(server) do
    size = AccessData.get_by(server, &Enum.count(&1))
    0..(size - 1)
  end

  defp aggregate_results({time, %{exit: error, ok: ok}}, queue) do
    %{
      queue: queue,
      time: time,
      ok: Enum.count(ok),
      errors: Enum.count(error)
    }
  end

  defp notify_sum(results) do
    # PubSub.broadcast(topic, queue_result) | GenStage.cast(stage, {:receive, queue_result})
    dbg(results)
  end
end
