defmodule Astrorunner.Card do
  @moduledoc """
  Card
  """

  defstruct(title: nil, costs: 0, image: "", text: "", rule: nil)

  alias Astrorunner.Card

  def card_types() do
    %{
      lab_assistent: %Card{title: "Labor Assistent", costs: 1, image: "", text: "upps!"}
    }
  end

  def build(name, n) do
    Enum.map(1..n, fn _n ->
      card_types()[name]
    end)
  end
end
