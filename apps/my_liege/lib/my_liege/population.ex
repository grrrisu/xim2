defmodule MyLiege.Population do
  @moduledoc """
  population consists of three generations
  needed food is per generation
  """
  alias MyLiege.Population
  defstruct gen_1: 0.0, gen_2: 0.0, gen_3: 0.0, needed_food: {1, 1, 1}

  def needed_food(%Population{
        gen_1: gen_1,
        gen_2: gen_2,
        gen_3: gen_3,
        needed_food: {needed_1, needed_2, needed_3}
      }) do
    gen_1 * needed_1 + gen_2 * needed_2 + gen_3 * needed_3
  end
end
