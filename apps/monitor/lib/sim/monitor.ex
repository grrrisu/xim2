defmodule Sim.Monitor do
  @moduledoc """
  Context for `Sim.Monitor`.
  """
  alias Ximula.Sim.{Loop, Queue}

  alias Sim.Monitor.Data

  @data_agent Sim.Monitor.Data
  @data_gatekeeper Sim.Monitor.Gatekeeper
  @loop_server Sim.Monitor.Loop
  @simulator_task_supervisor Sim.Monitor.Simulator.Task.Supervisor

  def create_data(size) do
    Data.create(@data_agent, size)
  end

  def get_data(key) do
    Data.get(@data_gatekeeper, key)
  end

  def prepare_queues(timeout, tasks) do
    Loop.add_queue(@loop_server, %Queue{
      name: :one,
      func:
        {Data, :run_queue,
         [
           timeout: timeout,
           tasks: tasks,
           gatekeeper: @data_gatekeeper,
           supervisor: @simulator_task_supervisor
         ]},
      interval: 1_000
    })
  end

  def start() do
    if Data.created?(@data_gatekeeper) do
      :ok = Loop.start_sim(@loop_server)
    else
      {:error, "data not yet created"}
    end
  end

  def stop() do
    :ok = Loop.stop_sim(@loop_server)
  end
end
