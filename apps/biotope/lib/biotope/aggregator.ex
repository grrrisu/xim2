defmodule Biotope.Aggregator do
  alias Biotope.Sim.Vegetation

  @doc """
  summary = %{vegetation: %{position => vegetation}, herbivore: %{position => herbivore}}
  """
  def aggregate_results({%{simulation: _, ok: ok, error: _}, summary}, _queue) do
    Enum.reduce(ok, summary, &aggregate(&1, &2))
  end

  def aggregate(%{change: change, origin: origin}, summary) do
    merge(summary, change, origin)
  end

  def merge(
        summary,
        %{vegetation: %{position: position} = change},
        %{vegetation: %Vegetation{} = origin}
      ) do
    get_and_update_in(summary, [:vegetation, position], fn previous ->
      case previous do
        nil -> may_replace(change, origin)
        {_prev, ori} -> may_replace(change, ori)
      end
    end)
    |> elem(1)
  end

  def may_replace(%{size: current} = change, %{size: previous} = origin) do
    if round(current) - round(previous) != 0 do
      {origin, {%{change | size: round(current)}, origin}}
    else
      :pop
    end
  end
end
