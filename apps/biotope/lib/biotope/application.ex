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
      {AccessProxy, name: Biotope.AccessProxy.Data, agent: Biotope.Data}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Biotope.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
