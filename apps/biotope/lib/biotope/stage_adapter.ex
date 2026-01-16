defmodule Biotope.StageAdapter do
  @behaviour Ximula.Sim.StageAdapter
  alias Ximula.Sim.Pipeline

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
    |> Pipeline.execute_steps(stage)
    |> Data.update(gatekeeper)
  end

  def sim_herbivore(key, %{gatekeeper: gatekeeper} = stage) do
    key
    |> Data.lock_herbivore(gatekeeper)
    |> Pipeline.execute_steps(stage)
    |> Data.update(gatekeeper)
  end
end
