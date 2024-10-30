defmodule MyLiege.Simulation.Population do
  @moduledoc """
  simulates the grows and deaths of the population
  """
  alias MyLiege.Population

  def sim_population(
        {change,
         %{
           working: working,
           poverty: poverty,
           birth_rate: birth_rate,
           death_rate: death_rate,
           disease_rate: disease_rate
         } = data, global}
      ) do
    change = Map.merge(change, %{working: working, poverty: poverty})

    {change, %{birth_rate: birth_rate, death_rate: death_rate, disease_rate: disease_rate}, %{}}
    |> grow_population()
    |> feed_population()
    |> shrink_population()
    |> then(fn {change, _, _} -> {change, data, global} end)
  end

  def grow_population(
        {%{
           working: working,
           poverty: poverty
         } = change, %{birth_rate: birth_rate} = data, %{} = global}
      ) do
    {%{
       change
       | working: grow_social_stratum(working, birth_rate),
         poverty: grow_social_stratum(poverty, birth_rate * 2)
     }, data, global}
  end

  def grow_social_stratum(%{gen_1: gen_1, gen_2: gen_2, gen_3: gen_3} = population, birth_rate) do
    %{
      population
      | gen_1: gen_1 * 0.75 + birth_rate * gen_3,
        gen_2: gen_2 * 0.75 + gen_1 * 0.25,
        gen_3: gen_3 + gen_2 * 0.25
    }
  end

  def shrink_population(
        {%{
           working: working,
           poverty: poverty
         } = change, %{death_rate: death_rate, disease_rate: disease_rate} = data, %{} = global}
      ) do
    {%{
       change
       | working: shrink_social_stratum(working, {death_rate, disease_rate}),
         poverty: shrink_social_stratum(poverty, {death_rate * 1.5, disease_rate * 1.5})
     }, data, global}
  end

  def shrink_social_stratum(
        %{gen_1: gen_1, gen_2: gen_2, gen_3: gen_3} = population,
        {death_rate, disease_rate}
      ) do
    %{
      population
      | gen_1: gen_1 - disease_rate * 1.5 * gen_1,
        gen_2: gen_2 - disease_rate * gen_2,
        gen_3: gen_3 - (death_rate + disease_rate) * gen_3
    }
  end

  def feed_population({
        %{food: food, working: working, poverty: poverty} = change,
        %{} = data,
        %{} = global
      }) do
    working_needed_food = Population.needed_food(working)
    poverty_needed_food = Population.needed_food(poverty)
    needed_food = working_needed_food + poverty_needed_food

    {food, working, poverty} =
      feed_population_with({food, working, poverty}, %{
        needed_food: needed_food,
        working_needed_food: working_needed_food,
        poverty_needed_food: poverty_needed_food
      })

    {
      Map.merge(change, %{food: food, working: working, poverty: poverty}),
      data,
      global
    }
  end

  def feed_population_with(
        {food, %Population{needed_food: {_, _, working_needed_food}} = working,
         %Population{needed_food: {_, _, poverty_needed_food}} = poverty},
        %{needed_food: needed_food}
      )
      when food >= needed_food do
    food_diff = working_needed_food - poverty_needed_food
    remaining_food = food - needed_food
    possible = remaining_food / food_diff
    possible = if possible < poverty.gen_3, do: possible, else: poverty.gen_3

    {remaining_food - possible * food_diff, Map.put(working, :gen_3, working.gen_3 + possible),
     Map.put(poverty, :gen_3, poverty.gen_3 - possible)}
  end

  def feed_population_with({food, working, poverty}, %{
        needed_food: needed_food,
        working_needed_food: working_needed_food,
        poverty_needed_food: poverty_needed_food
      })
      when food < needed_food do
    working_obtained_food = obtained_food(working, working_needed_food)
    poverty_obtained_food = obtained_food(poverty, poverty_needed_food)
    ratio = food / (working_obtained_food + poverty_obtained_food)

    new_working = feed_social_stratum(working, ratio * working_obtained_food)
    new_poverty = feed_social_stratum(poverty, ratio * poverty_obtained_food)
    {new_working, new_poverty} = working_to_poverty(working, new_working, new_poverty)

    {0.0, new_working, new_poverty}
  end

  def working_to_poverty(working, new_working, new_poverty)
      when working.gen_3 <= new_working.gen_3 do
    {new_working, new_poverty}
  end

  def working_to_poverty(
        working,
        %Population{needed_food: {_, _, working_needed_food}} = new_working,
        %Population{} = new_poverty
      )
      when working.gen_3 > new_working.gen_3 do
    dying = (working.gen_3 - new_working.gen_3) / working_needed_food
    possible = if new_working.gen_3 >= dying, do: dying, else: new_working.gen_3

    {Map.put(new_working, :gen_3, new_working.gen_3 - possible),
     Map.put(new_poverty, :gen_3, new_poverty.gen_3 + possible * working_needed_food)}
  end

  def obtained_food(population, needed_food) do
    population.spending_power * needed_food
  end

  def feed_social_stratum(
        %Population{
          gen_1: gen_1,
          gen_2: gen_2,
          gen_3: gen_3,
          needed_food: {needed_1, needed_2, needed_3}
        } = population,
        food
      ) do
    ratio = food / (gen_1 * needed_1 + gen_2 * needed_2 + gen_3 * needed_3)

    %{
      population
      | gen_1: ratio * gen_1,
        gen_2: ratio * gen_2,
        gen_3: ratio * gen_3
    }
  end
end
