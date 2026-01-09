defmodule Biotope.StageAdapter do
  @behaviour Ximula.Sim.StageAdapter
  alias Ximula.Sim.Pipeline

  alias Biotope.Data

  @impl true
  def run_stage(stage, %{data: data, opts: opts}) do
    case stage.name do
      :vegetation -> Pipeline.run_tasks(data, {__MODULE__, :sim_vegetation}, stage, opts)
    end
  end

  def sim_vegetation(key, %{gatekeeper: gatekeeper} = stage) do
    key
    |> Data.lock_field(:vegetation, gatekeeper)
    |> Pipeline.execute_steps(stage)
    |> Data.update(gatekeeper)
  end
end
