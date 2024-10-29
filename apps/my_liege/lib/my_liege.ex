defmodule MyLiege do
  @moduledoc false

  alias MyLiege.{Population, Simulation}

  @test_data %{
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
    death_rate: 0.1,
    disease_rate: 0.1
  }

  def create(server \\ MyLiege.Realm) do
    Agent.update(server, fn _ -> @test_data end)
  end

  def get_realm(server \\ MyLiege.Realm) do
    Agent.get(server, & &1)
  end

  def sim_step(server \\ MyLiege.Realm) do
    realm = Agent.get(server, & &1)
    realm = Simulation.sim({realm, %{}})
    Agent.update(server, fn _old -> realm end)
  end
end
