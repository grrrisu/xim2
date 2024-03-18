defmodule Biotope.Sim.Animal do
  alias Biotope.Data

  defmodule Herbivore do
    defstruct position: {0, 0},
              birth_rate: 0.5,
              death_rate: 0.01,
              needed_food: 5,
              starving_rate: 0.4,
              graze_rate: 0.05,
              size: 50

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
              birth_rate: 0.5,
              death_rate: 0.01,
              needed_food: 3,
              starving_rate: 0.3,
              graze_rate: 0.1,
              size: 10

    alias Biotope.Sim.Animal

    def sim(position, data: data) do
      %{key: position, data: data}
      |> Map.put_new(:origin, Data.lock_predator(position, data))
      |> then(&Map.put_new(&1, :change, Animal.grow(&1.origin.herbivore, &1.origin.predator)))
      |> Animal.round_size()
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
         herbivore: {position, %{size: herbivore.display_size, position: position}},
         predator: {position, %{size: predator.display_size, position: position}}
       }}
    end
  end

  def set_position(changeset, position) do
    changeset
    |> put_in([:change, :producer, :position], position)
    |> put_in([:change, :consumer, :position], position)
  end

  def round_size(
        %{change: %{producer: %{size: producer_size}, consumer: %{size: consumer_size}}} = change
      ) do
    change
    |> put_in([:change, :producer, :display_size], round(producer_size))
    |> put_in([:change, :producer, :priority], :normal)
    |> put_in([:change, :consumer, :display_size], round(consumer_size))
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

  def grow(producer, nil), do: {producer, nil}

  def grow(%{size: producer_size}, %{size: size} = animal, step \\ 1) do
    producer_size = producer_size - delta_producer(animal, producer_size) * step
    animal_size = size + delta_animal(animal, producer_size) * step

    %{producer: %{size: producer_size}, consumer: %{size: animal_size}}
  end

  def delta_producer(
        %{
          needed_food: needed_food,
          graze_rate: graze_rate,
          size: size
        },
        producer_size
      ) do
    (needed_food * size * graze_rate)
    |> max_consumed_food(producer_size)
  end

  defp max_consumed_food(consumed_food, producer) when producer - consumed_food < 0 do
    0
  end

  defp max_consumed_food(consumed_food, _producer), do: consumed_food

  def delta_animal(
        %{
          birth_rate: birth_rate,
          death_rate: death_rate,
          needed_food: needed_food,
          starving_rate: starving_rate,
          size: size
        },
        producer_size
      ) do
    hunger_rate = starving_rate * (size * needed_food / producer_size)

    (size * (birth_rate - hunger_rate - death_rate))
    |> min_grown_size(size, starving_rate)
  end

  defp min_grown_size(grown_size, size, starving_rate) when size + grown_size < 0 do
    -size * starving_rate * 2
  end

  defp min_grown_size(grown_size, _size, _starving_rate), do: grown_size
end
