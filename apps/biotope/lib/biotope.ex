defmodule Biotope do
  @moduledoc """
  Context for `Biotope`.
  """

  alias Biotope.Data
  alias Ximula.Sim.{Loop, Queue}

  @proxy Biotope.AccessProxy.Data
  @loop Biotope.Sim.Loop

  def all(proxy \\ @proxy) do
    Data.all(proxy)
  end

  def get(layer, proxy \\ @proxy) do
    Data.get(layer, proxy)
  end

  def get_field(position, layer, proxy \\ @proxy) do
    Data.get_field(position, layer, proxy)
  end

  def exclusive_get(layer, proxy \\ @proxy) do
    Data.exclusive_get(layer, proxy)
  end

  def create(width, height, proxy \\ @proxy) do
    Data.create(width, height, proxy)
  end

  # [{x, y, %{size: size}}, ...]
  def update(layer, changes, proxy \\ @proxy) do
    Data.update(layer, changes, proxy)
  end

  def clear(proxy \\ @proxy) do
    Data.clear(proxy)
  end

  def get_queues(loop \\ @loop) do
    Loop.get_queues(loop)
  end

  def prepare_sim_queues(loop \\ @loop, proxy \\ @proxy) do
    Loop.add_queue(loop, %Queue{
      name: :normal,
      func: {Biotope.Simulation, :sim, [data: proxy]},
      interval: 200
    })
  end

  def start(loop \\ @loop) do
    case all() do
      nil -> {:error, "no data available"}
      _ -> Loop.start_sim(loop)
    end
  end

  def stop(loop \\ @loop) do
    Loop.stop_sim(loop)
  end
end
