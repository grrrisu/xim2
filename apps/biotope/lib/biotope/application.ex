defmodule Biotope.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  alias Ximula.Gatekeeper.Server, as: Gatekeeper

  @impl true
  def start(_type, _args) do
    children = [
      Biotope.Data.agent_spec(Biotope.Data),
      {Gatekeeper, name: Biotope.Gatekeeper, context: %{agent: Biotope.Data}},
      {Ximula.Sim.Loop, name: Biotope.Sim.Loop, supervisor: Biotope.Sim.Loop.Task.Supervisor},
      {Task.Supervisor, name: Biotope.Simulator.Task.Supervisor},
      {Task.Supervisor, name: Biotope.Sim.Loop.Task.Supervisor}
    ]

    opts = [strategy: :rest_for_one, name: Biotope.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
