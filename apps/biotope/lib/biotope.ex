defmodule Biotope do
  @moduledoc """
  Context for `Biotope`.
  """

  alias Biotope.Data

  @proxy Biotope.AccessProxy.Data

  def get() do
    Data.get(@proxy)
  end

  def create(width, height) do
    Data.create(width, height, @proxy)
  end

  def clear() do
    Data.clear(@proxy)
  end
end
