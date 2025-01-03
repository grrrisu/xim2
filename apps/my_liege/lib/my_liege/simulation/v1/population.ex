defmodule MyLiege.Simulation.V1.Population do
  @moduledoc """
  simulates the grows and deaths of the population
  """
  alias MyLiege.{Population, Simulation}

  @doc """
  After the some time period peopel die and grow.
  The remaining one need to be fed.
  Important: the last function in row is the dominant one.
  In this case `feed_population`, this makes food the main factor that determines how the big the populaiton can grow.
  """
  def sim_population(
        {change,
         %{
           population: %{
             working: working,
             poverty: poverty,
             birth_rate: birth_rate,
             death_rate: death_rate,
             disease_rate: disease_rate
           }
         } = data, global}
      ) do
    change = Map.merge(change, %{working: working, poverty: poverty})

    {{change, [], nil},
     %{birth_rate: birth_rate, death_rate: death_rate, disease_rate: disease_rate}, global}
    |> log_change(:before)
    |> shrink_population()
    |> log_change(:shrink_population)
    |> grow_population()
    |> log_change(:grow_population)
    |> feed_population()
    |> log_change(:feed_population)
    |> notify_changes()
    |> add_population_changes(data)
  end

  def add_population_changes({%{food: food, working: working, poverty: poverty}, _, global}, data) do
    {%{food: food, population: %{working: working, poverty: poverty}}, data, global}
  end

  def log_change({{change, [], nil}, data, global}, sim_tag) do
    empty_population = %{working: %Population{}, poverty: %Population{}}
    {{change, [{sim_tag, change, calculate_delta(change, empty_population)}]}, data, global}
  end

  def log_change({{change, [{_sim_tag, before, _delta} | _] = log}, data, global}, sim_tag) do
    {{change, [{sim_tag, change, calculate_delta(change, before)} | log]}, data, global}
  end

  def calculate_delta(change, before) do
    %{
      working: %{
        gen_1: change.working.gen_1 - before.working.gen_1,
        gen_2: change.working.gen_2 - before.working.gen_2,
        gen_3: change.working.gen_3 - before.working.gen_3
      },
      poverty: %{
        gen_1: change.poverty.gen_1 - before.poverty.gen_1,
        gen_2: change.poverty.gen_2 - before.poverty.gen_2,
        gen_3: change.poverty.gen_3 - before.poverty.gen_3
      }
    }
  end

  def notify_changes({{change, log}, data, global}) do
    :ok = Simulation.notify({:population_simulated, log})
    {change, data, global}
  end

  def grow_population(
        {{%{
            working: working,
            poverty: poverty
          } = change, log}, %{birth_rate: birth_rate} = data, %{} = global}
      ) do
    {{%{
        change
        | working: grow_social_stratum(working, birth_rate),
          poverty: grow_social_stratum(poverty, birth_rate * 2)
      }, log}, data, global}
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
        {{%{
            working: working,
            poverty: poverty
          } = change, log}, %{death_rate: death_rate, disease_rate: disease_rate} = data,
         %{} = global}
      ) do
    {{%{
        change
        | working: shrink_social_stratum(working, {death_rate, disease_rate}),
          poverty: shrink_social_stratum(poverty, {death_rate * 1.5, disease_rate * 1.5})
      }, log}, data, global}
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
        {%{food: food, working: working, poverty: poverty} = change, log},
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
      {Map.merge(change, %{food: food, working: working, poverty: poverty}), log},
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

    remaining_food = remaining_food - possible * food_diff

    {remaining_food, Map.put(working, :gen_3, working.gen_3 + possible),
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
