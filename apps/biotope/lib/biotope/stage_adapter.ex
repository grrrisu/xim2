defmodule Biotope.StageAdapter do
  @behaviour Ximula.Sim.StageAdapter
  alias Ximula.Sim.{Change, Pipeline}

  alias Biotope.Data

  @impl true
  def run_stage(stage, %{data: _data, opts: opts}) do
    case stage.name do
      :vegetation ->
        Data.get_grid_positions(stage.gatekeeper)
        |> Pipeline.run_tasks({__MODULE__, :sim_vegetation}, stage, opts)

      :herbivore ->
        Data.get(:herbivore, stage.gatekeeper)
        |> Map.keys()
        |> Pipeline.run_tasks({__MODULE__, :sim_herbivore}, stage, opts)
    end
  end

  def sim_vegetation(key, %{gatekeeper: gatekeeper} = stage) do
    key
    |> Data.lock_field(:vegetation, gatekeeper)
    |> then(&%Change{data: &1})
    |> Pipeline.execute_steps(stage)
    |> tap(&update(&1, gatekeeper))
    |> mark_no_changes()
  end

  def sim_herbivore(key, %{gatekeeper: gatekeeper} = stage) do
    key
    |> Data.lock_herbivore(gatekeeper)
    |> then(&%Change{data: &1})
    |> Pipeline.execute_steps(stage)
    |> tap(&update(&1, gatekeeper))
    |> mark_no_changes()
  end

  defp update(change, gatekeeper) do
    change |> Change.reduce() |> Data.update(gatekeeper)
  end

  defp mark_no_changes(%Change{data: %{size: _size, position: position}} = change) do
    case Change.get_if_integer_threshold(change, :size) do
      :no_change -> :no_change
      size -> %{size: round(size), position: position}
    end
  end

  defp mark_no_changes(%Change{data: %{vegetation: %{size: _size, position: position}}} = change) do
    case Change.get_if_integer_threshold(change, [:vegetation, :size]) do
      :no_change ->
        :no_change

      size ->
        %{
          vegetation: %{size: round(size), position: position},
          herbivore: %{
            size: Change.get(change, [:herbivore, :size]) |> round(),
            position: position
          }
        }
    end
  end
end
