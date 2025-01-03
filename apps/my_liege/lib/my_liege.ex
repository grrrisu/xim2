defmodule MyLiege do
  @moduledoc false

  alias Phoenix.PubSub
  alias MyLiege.{Population, Simulation}

  @test_data %{
    storage: %{food: 94},
    population: %{
      working: %Population{
        gen_1: 10.0,
        gen_2: 10.0,
        gen_3: 10.0,
        needed_food: {1, 2, 3},
        spending_power: 3
      },
      poverty: %Population{
        gen_1: 10.0,
        gen_2: 10.0,
        gen_3: 10.0,
        needed_food: {1, 1, 1},
        spending_power: 1
      },
      birth_rate: 0.4,
      death_rate: 0.05,
      disease_rate: 0.08
    }
  }

  def create(server \\ MyLiege.Realm) do
    Agent.get_and_update(server, fn _ -> {@test_data, @test_data} end)
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
        realm = Agent.get(server, & &1)
        realm = Simulation.sim({realm, %{}})
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
