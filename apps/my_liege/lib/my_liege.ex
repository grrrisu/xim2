defmodule MyLiege do
  @moduledoc false

  alias MyLiege.{Population, Simulation}

  @test_data %{
    storage: %{food: 94},
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

  def create(server \\ MyLiege.Realm) do
    Agent.get_and_update(server, fn _ -> {@test_data, @test_data} end)
  end

  def get_realm(server \\ MyLiege.Realm) do
    Agent.get(server, & &1)
  end

  def update(values, server \\ MyLiege.Realm)

  def update(values, server) when is_map(values) do
    Agent.update(
      server,
      &Enum.reduce(&1, values, fn {{keys, value}, realm} -> put_in(realm, keys, value) end)
    )
  end

  def update({keys, value}, server) when is_list(keys) do
    Agent.update(server, &put_in(&1, keys, value))
  end

  def sim_step(server \\ MyLiege.Realm) do
    realm = Agent.get(server, & &1)
    realm = Simulation.sim({realm, %{}})
    Agent.update(server, fn _old -> realm end)
    realm
  end
end
