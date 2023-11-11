defmodule Biotope do
  @moduledoc """
  Context for `Biotope`.
  """

  alias Biotope.Data
  alias Ximula.Sim.{Loop, Queue}

  @proxy Biotope.AccessProxy.Data
  @loop Biotope.Sim.Loop

  def get(proxy \\ @proxy) do
    Data.get(proxy)
  end

  def exclusive_get(proxy \\ @proxy) do
    Data.exclusive_get(proxy)
  end

  def create(width, height, proxy \\ @proxy) do
    Data.create(width, height, proxy)
  end

  # [{x, y, %{size: size}}, ...]
  def update(changes, proxy \\ @proxy) do
    Data.update(changes, proxy)
  end

  def clear(proxy \\ @proxy) do
    Data.clear(proxy)
  end

  def get_queues(loop \\ @loop) do
    Loop.get_queues(loop)
  end

  def prepare_sim_queues(loop \\ @loop, proxy \\ @proxy) do
    Loop.set_queue(loop, %Queue{
      name: :normal,
      func: {Biotope.Simulation, :sim, [data: proxy]},
      interval: 200
    })
  end

  def start(loop \\ @loop) do
    case get() do
      nil -> {:error, "no data available"}
      _ -> Loop.start_sim(loop)
    end
  end

  def stop(loop \\ @loop) do
    Loop.stop_sim(loop)
  end
end
