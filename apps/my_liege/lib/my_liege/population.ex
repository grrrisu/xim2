defmodule MyLiege.Population.Generation do
  defstruct people: 0, grow_rem: 0, disease_rem: 0, age_rem: 0
end

defmodule MyLiege.Population do
  @moduledoc """
  population consists of three generations
  # needed food is per generation
  """

  # alias MyLiege.Population

  alias MyLiege.Population.Generation

  defstruct gen_1: %Generation{},
            gen_2: %Generation{},
            gen_3: %Generation{},
            needed_food: {1, 1, 1},
            spending_power: 1

  # def needed_food(%Population{
  #       gen_1: gen_1,
  #       gen_2: gen_2,
  #       gen_3: gen_3,
  #       needed_food: {needed_1, needed_2, needed_3}
  #     }) do
  #   gen_1 * needed_1 + gen_2 * needed_2 + gen_3 * needed_3
  # end
end
