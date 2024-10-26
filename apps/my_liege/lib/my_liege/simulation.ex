defmodule MyLiege.Simulation do
  @moduledoc """
  data = %{
    working: %{
      generation_1: 10,
      generation_2: 10,
      generation_3: 10,
      spending_power: 3
      birth_rate: 0.1
    }
  }
  """

  defstruct gen_1: 0, gen_2: 0, gen_3: 0

  def sim({data, global}) do
    # gather working population in factories for sim_population
    # if idle population after sim_population is negative, we need to remove poeple from the factories
    # if working + (negative) idle < 0 -> GAME over no population
    {%{}, data, global}
    |> harvest()
    |> sim_population()

    # |> handle_shrinking_workers()
  end

  def harvest({change, data, global}) do
    {Map.merge(change, %{food: 100}), data, global}
  end

  def sim_population({change, data, global}) do
    {change, data, global}
    |> grow_population()
    |> feed_population()

    # |> shrink_population()
  end

  def grow_population(
        {change,
         %{
           birth_rate: birth_rate,
           working: working,
           poverty: poverty
         } =
           population, %{} = _global}
      ) do
    new_change = %{
      working: grow_social_stratum(working, birth_rate),
      poverty: grow_social_stratum(poverty, birth_rate)
    }

    {Map.merge(change, new_change), population}
  end

  def grow_social_stratum(%{gen_1: gen_1, gen_2: gen_2, gen_3: gen_3} = population, birth_rate) do
    %{
      population
      | gen_1: gen_1 * 0.75 + birth_rate * gen_3,
        gen_2: gen_2 * 0.75 + gen_1 * 0.25,
        gen_3: gen_3 + gen_2 * 0.25
    }
  end

  def feed_population({
        %{food: food, working: working, poverty: poverty} = change,
        %{} = data,
        %{} = global
      }) do
    # 60
    working_needed_food = working.gen_1 + working.gen_2 * 2 + working.gen_3 * 3
    # 30
    poverty_needed_food = poverty.gen_1 + poverty.gen_2 + poverty.gen_3

    needed_food = working_needed_food + poverty_needed_food

    {food, working, poverty} =
      case food >= needed_food do
        true ->
          remaining_food = food - needed_food
          possible = (remaining_food / (3 - 1)) |> round()

          if possible <= poverty.gen_3 do
            {remaining_food - possible * (3 - 1),
             Map.put(working, :gen_3, working.gen_3 + possible),
             Map.put(poverty, :gen_3, poverty.gen_3 - possible)}
          else
            {remaining_food - poverty.gen_3 * (3 - 1),
             Map.put(working, :gen_3, working.gen_3 + poverty.gen_3), Map.put(poverty, :gen_3, 0)}
          end

        false ->
          # 45 / (180 + 30)
          ratio = food / (working_needed_food * 3 + poverty_needed_food * 1)
          # ratio * 180 => 39 | 6
          new_working =
            feed_social_stratum(working, ratio * working_needed_food * 3, {1, 2, 3})

          new_poverty =
            feed_social_stratum(poverty, ratio * poverty_needed_food * 1, {1, 1, 1})

          # if working.gen_3 > new_working.gen_3 do
          #   # needed food
          #   decline = (working.gen_3 - new_working.gen_3 / (3 - 1)) |> round()
          #   new_working = Map.put(new_working, :gen_3, new_working.gen_3 - decline)
          #   new_poverty = Map.put(new_poverty, :gen_3, new_poverty.gen_3 + decline * 3)
          # end
          {0.0, new_working, new_poverty}
      end

    {
      Map.merge(change, %{food: food, working: working, poverty: poverty}),
      data,
      global
    }
  end

  def feed_social_stratum(
        %{gen_1: gen_1, gen_2: gen_2, gen_3: gen_3} = population,
        food,
        {needed_1, needed_2, needed_3}
      ) do
    ratio = food / (gen_1 * needed_1 + gen_2 * needed_2 + gen_3 * needed_3)

    %{
      population
      | gen_1: ratio * gen_1,
        gen_2: ratio * gen_2,
        gen_3: ratio * gen_3
    }
  end

  def handle_shrinking_workers(_population_result, _data) do
    # if idle population after sim_population is negative, we need to remove poeple from the factories
    # if working + (negative) idle < 0 -> GAME over no population
  end
end
