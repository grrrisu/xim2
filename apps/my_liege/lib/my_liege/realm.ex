defmodule MyLiege.Realm do
  @moduledoc """
  Agent holding the (root) data
  """

  use Agent

  def start_link(opts) do
    Agent.start_link(fn -> %{} end, name: opts[:name])
  end
end
