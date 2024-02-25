defmodule Sim.Monitor do
  @moduledoc """
  Context for `Sim.Monitor`.
  """
  alias Ximula.Sim.{Loop, Queue}

  alias Sim.Monitor.Data

  @data_server Sim.Monitor.Data
  @loop_server Sim.Monitor.Loop
  @simulator_task_supervisor Sim.Monitor.Simulator.Task.Supervisor

  def create_data(size) do
    Data.create(@data_server, size)
  end

  def get_data(key) do
    Data.get(@data_server, key)
  end

  def prepare_queues() do
    Loop.add_queue(@loop_server, %Queue{
      name: :one,
      func: {Data, :run_queue, [data: @data_server, supervisor: @simulator_task_supervisor]},
      interval: 1_000
    })
  end

  def start() do
    if Data.created?(@data_server) do
      :ok = Loop.start_sim(@loop_server)
    else
      {:error, "data not yet created"}
    end
  end

  def stop() do
    :ok = Loop.stop_sim(@loop_server)
  end
end
