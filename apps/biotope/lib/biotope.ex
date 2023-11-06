defmodule Biotope do
  @moduledoc """
  Context for `Biotope`.
  """

  alias Biotope.{Data, Simulation}
  alias Ximula.Sim.{Loop, Queue}

  @proxy Biotope.AccessProxy.Data
  @loop Biotope.Sim.Loop

  def get() do
    Data.get(@proxy)
  end

  def exclusive_get() do
    Data.exclusive_get(@proxy)
  end

  def create(width, height) do
    Data.create(width, height, @proxy)
  end

  def clear() do
    Data.clear(@proxy)
  end
end
