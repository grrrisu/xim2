defmodule MyLiege.Simulation.Population do
  @moduledoc """

  time_unit: 1 month

  per year:
  working gen_1: 20 people, -2 disease, -6 grow to gen_2 -> needs 8 -> produces for gen_2 (12/6) * 20 = 40
          gen_2: 20 people, -1 disease, -5 grow to gen_3 -> needs 6 -> produces for gen_3 (12/5) * 20 = 48
          gen_3: 40 people, -2 disease, -1 dies, +2 population grow -> needs 3 plus 2 = 5 -> produces for gen_1 (12/8) * 40 = 60

  """
  alias MyLiege.Population

  import MyLiege.Simulation.Unit

  def needed_per_year(value, population) do
    round(12 / value * population)
  end

  def working() do
    %{
      gen_1: %{
        grow: %{needed: needed_per_year(6, 20), output: 1},
        disease: %{needed: needed_per_year(2, 20), output: 1}
      },
      gen_2: %{
        grow: %{needed: needed_per_year(5, 20), output: 1},
        disease: %{needed: needed_per_year(1, 20), output: 1}
      },
      gen_3: %{
        grow: %{needed: needed_per_year(8, 40), output: 1},
        disease: %{needed: needed_per_year(2, 40), output: 1},
        age: %{needed: needed_per_year(1, 40), output: 1}
      }
    }
  end

  def sim_population({change, data, global}) do
    population =
      Enum.reduce(data.population, change, fn {social_class, population}, change ->
        change
        |> Map.put(social_class, sim_social_class(population))
      end)

    {Map.put(change, :population, population), data, global}
  end

  def sim_social_class(%Population{} = population) do
    population
    |> grow()
    |> shrink()
  end

  def grow(%{gen_1: gen_1, gen_2: gen_2, gen_3: gen_3} = population) do
    {gen_1, output_1} = change_generation(gen_1, :grow_rem, working().gen_1.grow)
    {gen_2, output_2} = change_generation(gen_2, :grow_rem, working().gen_2.grow)
    {gen_3, output_3} = change_generation(gen_3, :grow_rem, working().gen_3.grow)
    gen_1 = %{gen_1 | people: gen_1.people - output_1 + output_3}
    gen_2 = %{gen_2 | people: gen_2.people - output_2 + output_1}
    gen_3 = %{gen_3 | people: gen_3.people + output_2}
    %{population | gen_1: gen_1, gen_2: gen_2, gen_3: gen_3}
  end

  def shrink(%{gen_1: gen_1, gen_2: gen_2, gen_3: gen_3} = population) do
    {gen_1, disease_1} = change_generation(gen_1, :disease_rem, working().gen_1.disease)
    {gen_2, disease_2} = change_generation(gen_2, :disease_rem, working().gen_2.disease)
    {gen_3, disease_3} = change_generation(gen_3, :disease_rem, working().gen_3.disease)
    {gen_3, age_3} = change_generation(gen_3, :age_rem, working().gen_3.age)
    gen_1 = %{gen_1 | people: gen_1.people - disease_1}
    gen_2 = %{gen_2 | people: gen_2.people - disease_2}
    gen_3 = %{gen_3 | people: gen_3.people - disease_3 - age_3}
    %{population | gen_1: gen_1, gen_2: gen_2, gen_3: gen_3}
  end

  defp change_generation(%{people: people} = generation, key, config) do
    {rem, output} = process_input(people, Map.get(generation, key), config)
    {Map.put(generation, key, rem), output}
  end
end
