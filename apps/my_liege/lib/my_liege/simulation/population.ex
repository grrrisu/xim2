defmodule MyLiege.Simulation.Population do
  @moduledoc """

  time_unit: 1 month

  working gen_1: 20 people, -2 disease, -6 grow to gen_2 -> needs 8 -> produces for gen_2 (12/6) * 20 = 40
          gen_2: 20 people, -1 disease, -5 grow to gen_3 -> needs 6 -> produces for gen_3 (12/5) * 20 = 48
          gen_3: 40 people, -2 disease, -1 dies, +2 population grow -> needs 3 plus 2 = 5 -> produces for gen_1 (12/8) * 40 = 60

  """

  @working %{
    gen_1: %{input: 40, output: 1},
    gen_2: %{input: 48, output: 1},
    gen_3: %{input: 60, output: 1}
  }

  def grow_gen(%{people: people, work_done: work_done} = population, config) do
    grow_output(population, config, people + work_done)
  end

  def grow_output(population, %{input: input}, new_work) when new_work < input do
    {%{population | work_done: new_work}, 0}
  end

  def grow_output(population, %{input: input, output: output}, new_work) when new_work >= input do
    {%{population | work_done: new_work - input}, output}
  end

  def grow(%{gen_1: gen_1, gen_2: gen_2, gen_3: gen_3} = population) do
    {gen_1, output_1} = grow_gen(gen_1, @working.gen_1)
    {gen_2, output_2} = grow_gen(gen_2, @working.gen_2)
    {gen_3, output_3} = grow_gen(gen_3, @working.gen_3)
    gen_1 = %{gen_1 | people: gen_1.people - output_1 + output_3}
    gen_2 = %{gen_2 | people: gen_2.people - output_2 + output_1}
    gen_3 = %{gen_3 | people: gen_3.people + output_2}
    %{population | gen_1: gen_1, gen_2: gen_2, gen_3: gen_3}
  end
end
