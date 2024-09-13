defmodule Astrorunner.Card do
  @moduledoc """
  Card
  """

  defstruct(id: nil, title: nil, type: :mission, costs: 0, image: "", text: "", rules: [])

  alias Astrorunner.Card

  def card_types() do
    %{
      flight_director: %Card{
        title: "Flug Direktor",
        type: :mission,
        costs: 1,
        image: "flight_director.jpg",
        text: "Listen up! I need go / no go"
      },
      lab_assistent: %Card{
        title: "Labor Assistent",
        type: :research,
        costs: 1,
        image: "lab_assistant.jpg",
        text: "upps!",
        rules: [%{xp: 1}]
      },
      tinkerer: %Card{
        title: "Tüftler",
        type: :engineer,
        costs: 2,
        image: "tinkerer.jpg",
        text: "let's try this ...",
        rules: [%{engineer: 1}, %{gear: 1, engineer: -1}]
      },
      mathematician: %Card{
        title: "Mathematikerin",
        type: :research,
        costs: 2,
        image: "mathematician.jpg",
        text: "so then x is ...",
        rules: [math: 2]
      },
      racing_car_mechanic: %Card{
        title: "Rennauto Mechanikerin",
        type: :engineer,
        costs: 2,
        image: "racing_car_mechanic.jpg",
        text: "I can make it faster",
        rules: [gear: 1]
      },
      trouble_shooter: %Card{
        title: "Trouble Shooter",
        type: :mission,
        costs: 2,
        image: "trouble_shooter.jpg",
        text: "Wait jsut a moment!",
        rules: []
      },
      tester: %Card{
        title: "Tester",
        type: :mission,
        costs: 2,
        image: "tester.jpg",
        text: "Let' retry this again!",
        rules: []
      },
      data_analyst: %Card{
        title: "Daten Analystin",
        type: :mission,
        costs: 2,
        image: "data_analyst.jpg",
        text: "This looks interesting"
      },
      stuntmen: %Card{
        title: "Stuntmen",
        type: :pilot,
        costs: 2,
        image: "stuntmen.jpg",
        text: "tell me where to crash!"
      },
      line_pilot: %Card{
        title: "Linien Pilotin",
        type: :pilot,
        costs: 4,
        image: "line_pilot.jpg",
        text: "have nice flight"
      },
      test_pilot: %Card{
        title: "Test Pilot",
        type: :pilot,
        costs: 7,
        image: "test_pilot.jpg",
        text: "to infinity and beyond!"
      }
    }
  end

  def build(name, n \\ 1) do
    Enum.map(1..n, fn _n ->
      card_types()[name] |> Map.put(:id, System.unique_integer([:positive]))
    end)
  end
end
