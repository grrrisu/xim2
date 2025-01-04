defmodule MyLiege.Simulation.Population do
  @moduledoc """

  time_unit: 1 month

  working gen_1: 20 people, -2 disease, -6 grow to gen_2 -> needs 8 -> produces for gen_2 (12/6) * 20 = 40
          gen_2: 20 people, -1 disease, -5 grow to gen_3 -> needs 6 -> produces for gen_3 (12/5) * 20 = 48
          gen_3: 40 people, -2 disease, -1 dies, +2 population grow -> needs 3 plus 2 = 5 -> produces for gen_1 (12/8) * 40 = 60

  """

  import MyLiege.Simulation.Unit

  @working %{
    gen_1: %{
      grow: %{needed: 40, output: 1},
      disease: %{needed: 120, output: -1}
    },
    gen_2: %{
      grow: %{needed: 48, output: 1},
      disease: %{needed: 240, output: -1}
    },
    gen_3: %{
      grow: %{needed: 60, output: 1},
      disease: %{needed: 240, output: -1},
      age: %{needed: 480, output: -1}
    }
  }

  def grow(%{gen_1: gen_1, gen_2: gen_2, gen_3: gen_3} = population) do
    {gen_1, output_1} = grow_generation(gen_1, @working.gen_1.grow)
    {gen_2, output_2} = grow_generation(gen_2, @working.gen_2.grow)
    {gen_3, output_3} = grow_generation(gen_3, @working.gen_3.grow)
    gen_1 = %{gen_1 | people: gen_1.people - output_1 + output_3}
    gen_2 = %{gen_2 | people: gen_2.people - output_2 + output_1}
    gen_3 = %{gen_3 | people: gen_3.people + output_2}
    %{population | gen_1: gen_1, gen_2: gen_2, gen_3: gen_3}
  end

  defp grow_generation(%{people: people, grow_rem: grow_rem} = generation, config) do
    {grow_rem, output} = process_input(people, grow_rem, config)
    {%{generation | grow_rem: grow_rem}, output}
  end

  def shrink(%{gen_1: gen_1, gen_2: gen_2, gen_3: gen_3} = population) do
  end
end
