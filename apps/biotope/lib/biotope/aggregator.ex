defmodule Biotope.Aggregator do
  @doc """
  returns
  %{
    vegetation: [%{position: {0, 0}, size: 306}, %{position: {0, 2}, size: 5901}],
    herbivore: [%{position: {0, 3}, size: 550}],
    predator: []
  }
  """
  def aggregate_simulations([%{simulation: _, ok: _, error: _} | _] = results, _queue) do
    aggregate = %{vegetation: %{}, herbivore: %{}, predator: %{}}

    results
    |> Enum.map(& &1.ok)
    |> Enum.reduce(aggregate, &aggregate_results(&1, &2))
    |> Enum.reduce(%{}, fn {simulation, summary}, sum ->
      Map.put_new(sum, simulation, Map.values(summary) |> Enum.map(&elem(&1, 0)))
    end)
  end

  def aggregate_results(results, summary) do
    Enum.reduce(results, summary, fn result, sum ->
      sum
      |> merge_layer(:vegetation, result)
      |> merge_layer(:herbivore, result)
      |> merge_layer(:predator, result)
    end)
  end

  def merge_layer(summary, layer, result) do
    merge_change(summary, layer, Map.get(result, layer))
  end

  def merge_change(summary, _layer, nil), do: summary

  def merge_change(summary, layer, %{change: change, origin: origin}) do
    get_and_update_in(summary, [layer, change.position], fn previous ->
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
