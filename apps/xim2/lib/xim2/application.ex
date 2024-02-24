defmodule Xim2.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      Xim2.Repo,
      {DNSCluster, query: Application.get_env(:xim2, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Xim2.PubSub}
      # Start the Finch HTTP client for sending emails
      # {Finch, name: Xim2.Finch}
      # Start a worker by calling: Xim2.Worker.start_link(arg)
      # {Xim2.Worker, arg}
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: Xim2.Supervisor)
  end
end
