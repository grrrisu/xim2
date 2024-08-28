defmodule Astrorunner.Card do
  @moduledoc """
  Card
  """

  defstruct(title: nil, costs: 0, image: "", text: "", rule: nil)

  alias Astrorunner.Card

  def card_types() do
    %{
      lab_assistent: %Card{title: "Labor Assistent", costs: 1, image: "", text: "upps!"},
      tinkerer: %Card{title: "Tüftler", costs: 2, image: "", text: "let's try this ..."},
      stuntmen: %Card{title: "Stuntmen", costs: 2, image: "", text: "tell me where to crash!"},
      line_pilot: %Card{title: "Linien Pilotin", costs: 4, image: "", text: "have nice flight"},
      test_pilot: %Card{title: "Test Pilot", costs: 7, image: "", text: "to infinity and beyond!"}
    }
  end

  def build(name, n) do
    Enum.map(1..n, fn _n ->
      card_types()[name]
    end)
  end
end
