defmodule Sim.Monitor.Data do
  @moduledoc """
  the simulation dummy data
  """

  alias Phoenix.PubSub

  alias Ximula.Gatekeeper.Agent, as: Gatekeeper
  alias Ximula.Sim.TaskRunner

  def create(server, size) do
    data = 0..(size - 1) |> Enum.reduce(%{}, &Map.put_new(&2, &1, %{value: 0}))
    :ok = Gatekeeper.direct_set(server, fn _data -> data end)
  end

  def created?(server) do
    Gatekeeper.get(server, fn data -> !is_nil(data) end)
  end

  def get(server, key) do
    Gatekeeper.get(server, &Map.get(&1, key))
  end

  def change(key, {:gatekeeper, gatekeeper}, {:timeout, timeout}) do
    value = Gatekeeper.lock(gatekeeper, key, fn data -> get_in(data, [key, :value]) end)

    timeout |> div(1000) |> Process.sleep()

    Gatekeeper.update(gatekeeper, key, fn data ->
      put_in(data, [key, :value], value + 1)
    end)

    {key, value}
  end

  # def change(one, two), do: raise(inspect([one, two]))

  def run_queue(
        timeout: timeout,
        tasks: tasks,
        gatekeeper: gatekeeper,
        supervisor: supervisor
      ) do
    TaskRunner.benchmark(fn ->
      get_items(gatekeeper)
      |> TaskRunner.sim(
        {__MODULE__, :change, gatekeeper: gatekeeper, timeout: timeout},
        supervisor,
        max_concurrency: tasks
      )

      # |> handle_success()
      # |> handle_failed()
      # |> summarize(simulation)
      # |> notify()
    end)
    |> aggregate_results()
    |> notify_sum()
  end

  defp get_items(server) do
    size = Gatekeeper.get(server, &Enum.count(&1))
    0..(size - 1) |> Range.to_list()
  end

  defp aggregate_results({duration, %{exit: error, ok: ok}}) do
    %{
      results: %{
        :one => %{
          ok: Enum.count(ok),
          error: Enum.count(error),
          time: DateTime.now!("Etc/UTC"),
          duration: duration,
          key: "some key",
          meta: %{}
        }
      }
    }
  end

  defp notify_sum(results) do
    PubSub.broadcast(Xim2.PubSub, "monitor:data", {:monitor_data, :queue_summary, results})
  end
end
