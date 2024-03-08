defmodule Sim.Monitor.Application do
  @moduledoc false

  use Application

  alias Ximula.AccessData
  alias Ximula.Sim.Loop

  @impl true
  def start(_type, _args) do
    children = [
      {AccessData, name: Sim.Monitor.Data, data: nil},
      {Loop, name: Sim.Monitor.Loop, supervisor: Sim.Monitor.Loop.Task.Supervisor},
      {Task.Supervisor, name: Sim.Monitor.Simulator.Task.Supervisor},
      {Task.Supervisor, name: Sim.Monitor.Loop.Task.Supervisor}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :rest_for_one, name: Sim.Monitor.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
