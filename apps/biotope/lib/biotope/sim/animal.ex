defmodule Biotope.Sim.Animal do
  alias Biotope.Data

  defmodule Herbivore do
    defstruct position: {0, 0},
              birth_rate: 0.5,
              death_rate: 0.01,
              needed_food: 5,
              starving_rate: 0.8,
              graze_rate: 0.05,
              size: 150

    alias Biotope.Sim.Animal

    def sim(position, data: data) do
      %{key: position, data: data}
      |> Map.put_new(:origin, Data.lock_herbivore(position, data))
      |> then(&Map.put_new(&1, :change, Animal.grow(&1.origin.vegetation, &1.origin.herbivore)))
      |> Animal.set_position(position)
      |> update_data()
      |> result()
    end

    def update_data(%{change: change, origin: origin, key: position, data: data} = changeset) do
      Data.update(
        {
          Map.merge(origin.vegetation, change.producer),
          Map.merge(origin.herbivore, change.consumer)
        },
        position,
        data
      )

      changeset
    end

    def result(%{
          change: %{producer: vegetation, consumer: herbivore},
          origin: origin
        }) do
      %{
        vegetation: %{change: vegetation, origin: origin.vegetation},
        herbivore: %{change: herbivore, origin: origin.herbivore}
      }
    end
  end

  defmodule Predator do
    defstruct position: {0, 0},
              birth_rate: 0.3,
              death_rate: 0.01,
              needed_food: 2,
              starving_rate: 0.5,
              graze_rate: 0.1,
              size: 10

    alias Biotope.Sim.Animal

    def sim(position, data: data) do
      %{key: position, data: data}
      |> Map.put_new(:origin, Data.lock_predator(position, data))
      |> then(&Map.put_new(&1, :change, Animal.grow(&1.origin.herbivore, &1.origin.predator)))
      |> Animal.set_position(position)
      |> update_data()
      |> result()
    end

    def update_data(%{change: change, origin: origin, key: position, data: data} = changeset) do
      Data.update(
        {
          Map.merge(origin.herbivore, change.producer),
          Map.merge(origin.predator, change.consumer)
        },
        position,
        data
      )

      changeset
    end

    def result(%{change: %{producer: herbivore, consumer: predator}, key: position}) do
      {position,
       %{
         herbivore: {position, %{size: herbivore.size, position: position}},
         predator: {position, %{size: predator.size, position: position}}
       }}
    end
  end

  def set_position(changeset, position) do
    changeset
    |> put_in([:change, :producer, :position], position)
    |> put_in([:change, :consumer, :position], position)
  end

  # population grows by birth rate and and and shrinks by death rate (age) and hunger.
  # Hunger is the ratio of needed food and food available multiplied by starving_rate.
  # The food consumed is proportional to the size of the population multiplied by graze_rate.
  #
  # b : birth_rate
  # d : death_rate
  # f : needed_food per unit
  # g : graze_rate / hunt_rate
  # a : starving_rate
  # s : size
  # v : producer.size
  #

  # Δv = - f s g

  #                s f
  # Δs = s (b - a ------  - d)
  #                 v

  def grow(producer, animal, step \\ 1)

  def grow(producer, nil, _step), do: %{producer: %{size: producer.size}}

  def grow(nil, %{size: size} = animal, step) do
    {0, animal_size} = calculate_delta(false, %{size: 0}, animal)
    %{consumer: %{size: size + animal_size * step}}
  end

  def grow(%{size: producer_size} = producer, %{size: size} = animal, step) do
    {consumed_food, animal_size} =
      calculate_delta(
        size * animal.needed_food / animal.graze_rate <= producer_size,
        producer,
        animal
      )

    %{
      producer: %{size: (producer_size - consumed_food * step) |> min_zero()},
      consumer: %{size: size + animal_size * step}
    }
  end

  # enough food
  def calculate_delta(true, _producer, %{size: size} = animal) do
    growth = size * (animal.birth_rate - animal.death_rate)
    {size * animal.needed_food, growth}
  end

  # not enough food
  def calculate_delta(false, %{size: producer_size}, %{size: size} = animal) do
    needed_producers = size * animal.needed_food / animal.graze_rate

    starving_rate =
      animal.starving_rate * (needed_producers - producer_size) / needed_producers

    starved = size * starving_rate
    growth = size * (animal.birth_rate - animal.death_rate)

    {producer_size * animal.graze_rate, growth - starved}
  end

  def min_zero(n) when n < 0, do: 0
  def min_zero(n), do: n
end
