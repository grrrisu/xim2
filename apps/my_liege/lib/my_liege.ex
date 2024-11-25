defmodule MyLiege do
  @moduledoc false

  alias Phoenix.PubSub
  alias MyLiege.{Scenario, Simulation}

  def create(scenario, server \\ MyLiege.Realm) do
    data = Scenario.get(scenario)
    Agent.get_and_update(server, fn _ -> {data, data} end)
  end

  def get_realm(server \\ MyLiege.Realm) do
    Agent.get(server, & &1)
  end

  def get_property(property, server \\ MyLiege.Realm) when is_binary(property) do
    Agent.get(server, &get_in(&1, property_path(property)))
  end

  def update(values, server \\ MyLiege.Realm)

  def update(values, server) when is_map(values) do
    Agent.update(
      server,
      &Enum.reduce(&1, values, fn {{keys, value}, realm} -> put_in(realm, keys, value) end)
    )
  end

  def update({property, value}, server) when is_binary(property) and is_binary(value) do
    {value, _} = Float.parse(value)
    Agent.update(server, &put_in(&1, property_path(property), value))
  end

  def update({keys, value}, server) when is_list(keys) do
    Agent.update(server, &put_in(&1, keys, value))
  end

  def sim_step(server \\ MyLiege.Realm) do
    {:ok, _pid} =
      Task.Supervisor.start_child(MyLiege.TaskSupervisor, fn ->
        realm =
          server
          |> Agent.get(& &1)
          |> Simulation.sim()

        :ok = Agent.update(server, fn _old -> realm end)
        :ok = PubSub.broadcast(Xim2Web.PubSub, "my_liege", {:realm_updated, realm})
      end)

    :ok
  end

  def property_path(property) do
    property
    |> String.split(".")
    |> Enum.map(&String.to_atom(&1))
  end
end
