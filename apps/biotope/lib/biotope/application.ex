defmodule Biotope.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  alias Ximula.AccessProxy

  @impl true
  def start(_type, _args) do
    children = [
      {Biotope.Data, name: Biotope.Data},
      {AccessProxy, name: Biotope.AccessProxy.Data, agent: Biotope.Data},
      {Ximula.Sim.Loop, name: Biotope.Sim.Loop, supervisor: Biotope.Sim.Loop.Task.Supervisor},
      {Task.Supervisor, name: Biotope.Simulator.Task.Supervisor},
      {Task.Supervisor, name: Biotope.Sim.Loop.Task.Supervisor}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :rest_for_one, name: Biotope.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
