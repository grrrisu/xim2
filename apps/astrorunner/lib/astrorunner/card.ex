defmodule Astrorunner.Card do
  @moduledoc """
  Card
  """

  defstruct(title: nil, type: :mission, costs: 0, image: "", text: "", rule: nil)

  alias Astrorunner.Card

  def card_types() do
    %{
      lab_assistent: %Card{
        title: "Labor Assistent",
        type: :research,
        costs: 1,
        image: "",
        text: "upps!"
      },
      tinkerer: %Card{
        title: "Tüftler",
        type: :engineer,
        costs: 2,
        image: "",
        text: "let's try this ..."
      },
      stuntmen: %Card{
        title: "Stuntmen",
        type: :pilot,
        costs: 2,
        image: "",
        text: "tell me where to crash!"
      },
      line_pilot: %Card{
        title: "Linien Pilotin",
        type: :pilot,
        costs: 4,
        image: "",
        text: "have nice flight"
      },
      test_pilot: %Card{
        title: "Test Pilot",
        type: :pilot,
        costs: 7,
        image: "",
        text: "to infinity and beyond!"
      }
    }
  end

  def build(name, n \\ 1) do
    Enum.map(1..n, fn _n ->
      card_types()[name]
    end)
  end
end
