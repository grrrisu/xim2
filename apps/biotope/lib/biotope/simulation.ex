defmodule Biotope.Simulation do
  use Ximula.Sim

  alias Ximula.Sim.Change
  alias Biotope.Simulation
  alias Biotope.Sim.{Vegetation}
  alias Biotope.StageAdapter

  simulation do
    default(gatekeeper: Biotope.Gatekeeper, pubsub: Xim2.PubSub)

    pipeline(:biotop) do
      notify(:metric)

      stage(:vegetation, StageAdapter) do
        notify_all(:event_metric)
        notify_entity(:metric, &Simulation.notify_filter/1)
        step(Vegetation, :sim, notify: {:metric, &Simulation.notify_filter/1})
      end

      # stage(:herbivore, StageAdapter) do
      #   notify_all(:metric)
      #   notify_entity(:metric, &Simulation.notify_filter/1)
      #   step(Herbivore, :sim, notify: {:metric, &Simulation.notify_filter/1})
      # end
    end

    queue :normal, 200 do
      run_pipeline(:biotop, supervisor: Biotope.Simulator.Task.Supervisor)
    end
  end

  def notify_filter(%Change{} = change) do
    Change.get(change, :position) == {0, 0}
  end

  def notify_filter(field) do
    field.position == {0, 0}
  end
end
