defmodule Xim2Web.MonitorLive.Index do
  use Xim2Web, :live_view

  require Logger

  import Xim2Web.Monitor.Components

  @items 500
  @timeout 50_000
  @tasks 500

  def mount(%{"topic" => _topic, "data" => data} = params, _session, socket) do
    if connected?(socket), do: attach_telemetry()

    {:ok,
     socket
     |> assign(:page_title, "Monitor #{data}")
     |> prepare_sim_stack_chart("duration-sim-stack-chart",
       fill: true,
       begin_at_zero: true
     )
     |> prepare_biotope_chart("duration-summary-chart",
       fill: true,
       stacked: true,
       begin_at_zero: true
     )
     |> prepare_biotope_chart("ok-summary-chart", fill: false, begin_at_zero: true)
     |> prepare_biotope_chart("changed-summary-chart",
       fill: true,
       stacked: true,
       begin_at_zero: true
     )
     |> prepare_biotope_chart("errors-summary-chart",
       type: "bar",
       fill: false,
       begin_at_zero: true
     )
     |> assign(
       pubsub_topic: pubsub_topic(params),
       running: false,
       schedulers: System.schedulers_online(),
       tasks: @tasks,
       items: @items,
       timeout: @timeout
     )
     |> stream(:sim_stack_durations, [])
     |> stream(:durations, [])
     |> stream(:error_messages, [])}
  end

  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} title={@page_title} back={~p"/"}>
      <.box_grid>
        <:box><.chart title="Sim Stack Duration" name="duration-sim-stack-chart" hook="ChartAsync" /></:box>
        <:box>
          <.duration_table durations={@streams.sim_stack_durations} items={nil} tasks={nil} timeout={nil} />
        </:box>
      </.box_grid>
      <.box_grid>
        <:box><.chart title="Duration" name="duration-summary-chart" hook="Chart" /></:box>
        <:box>
          <.duration_table durations={@streams.durations} items={nil} tasks={nil} timeout={nil} />
        </:box>
      </.box_grid>
      <.box_grid>
        <:box><.chart title="Items calculated" name="ok-summary-chart" hook="Chart" /></:box>
        <:box><.chart title="Items changed" name="changed-summary-chart" hook="Chart" /></:box>
      </.box_grid>
      <.box_grid>
        <:box><.chart title="Errors" name="errors-summary-chart" hook="Chart" /></:box>
        <:box>
          <.error_message_table error_messages={@streams.error_messages} />
        </:box>
      </.box_grid>
    </Layouts.app>
    """
  end

  def handle_telemetry_event(event, measurements, metadata, %{pid: pid}) do
    send(pid, {:telemetry_event, event, measurements, metadata})
  end

  def handle_info(
        {:telemetry_event, event, measurements, metadata},
        socket
      ) do
    metadata =
      Map.take(metadata, [
        :duration,
        :name,
        :stage_name,
        :ok,
        :failed,
        :module,
        :function
      ])

    case event do
      [:ximula, :sim, :pipeline, :stage, :step, :stop] ->
        {:noreply,
         socket
         |> push_chart_data("duration-sim-stack-chart", 0, measurements.duration)
         |> insert_sim_stack_duration(:step, measurements.duration, metadata)}

      [:ximula, :sim, :pipeline, :stage, :entity, :stop] ->
        {:noreply,
         socket
         |> push_chart_data("duration-sim-stack-chart", 1, measurements.duration)
         |> insert_sim_stack_duration(:entity, measurements.duration, metadata)}

      [:ximula, :sim, :pipeline, :stage, :stop] ->
        {:noreply,
         socket
         |> push_chart_data("duration-sim-stack-chart", 2, measurements.duration)
         |> insert_sim_stack_duration(:stage, measurements.duration, metadata)}

      [:ximula, :sim, :pipeline, :stop] ->
        {:noreply,
         socket
         |> push_chart_data("duration-sim-stack-chart", 3, measurements.duration)
         |> insert_sim_stack_duration(:pipeline, measurements.duration, metadata)}

      [:ximula, :sim, :queue, :stop] ->
        {:noreply,
         socket
         |> push_chart_data("duration-sim-stack-chart", 4, measurements.duration)
         |> insert_sim_stack_duration(:queue, measurements.duration, metadata)}

      _ ->
        {:noreply, socket}
    end
  end

  # def handle_info({:monitor_data, :queue_summary, result}, socket) do
  #   {:noreply,
  #    socket
  #    |> stream_insert(
  #      :durations,
  #      Map.put_new(result, :id, System.unique_integer([:positive])),
  #      limit: -12
  #    )
  #    |> push_event("update-duration-chart", %{
  #      x_axis: DateTime.to_iso8601(result.time),
  #      duration: result.duration
  #    })}
  # end

  def handle_info(
        {namespace, :entities_changed, results},
        %{assigns: %{pubsub_topic: namespace}} = socket
      ) do
    {:noreply,
     socket
     |> push_chart_data("changed-summary-chart", [
       Enum.count(results.vegetation),
       Enum.count(results.herbivore),
       Enum.count(results.predator)
     ])}
  end

  def handle_info(
        {namespace, :simulation_errors, results},
        %{assigns: %{pubsub_topic: namespace}} = socket
      ) do
    {:noreply,
     Enum.reduce(results, socket, fn {{x, y}, message}, socket ->
       stream_insert(
         socket,
         :error_messages,
         %{
           id: System.unique_integer([:positive]),
           time: DateTime.now!("Etc/UTC"),
           entity: "{#{x}, #{y}}",
           message: message
         },
         limit: -12
       )
     end)}
  end

  def handle_info(
        {namespace, :queue_summary, %{results: results}},
        %{assigns: %{pubsub_topic: namespace}} = socket
      ) do
    {:noreply,
     socket
     |> insert_total_duration(results)
     |> push_chart_data("duration-summary-chart", biotope_results(results, :time))
     |> push_chart_data("ok-summary-chart", biotope_results(results, :ok))
     |> push_chart_data("errors-summary-chart", biotope_results(results, :error))}
  end

  def handle_info({namespace, topic, _payload}, %{assigns: %{pubsub_topic: namespace}} = socket) do
    Logger.info("received simulation #{namespace} topic #{topic}")
    {:noreply, socket}
  end

  def handle_info(msg, socket) do
    Logger.warning("unhandled message #{inspect(msg)}")
    {:noreply, socket}
  end

  defp insert_sim_stack_duration(socket, key, duration, meta) do
    socket
    |> stream_insert(
      :sim_stack_durations,
      %{
        id: System.unique_integer([:positive]),
        key: key,
        time: DateTime.now!("Etc/UTC"),
        duration: duration,
        meta: meta
      },
      limit: -12
    )
  end

  defp insert_total_duration(socket, results) do
    socket
    |> stream_insert(
      :durations,
      %{
        id: System.unique_integer([:positive]),
        time: DateTime.now!("Etc/UTC"),
        duration: Enum.reduce(results, 0, fn {_, result}, sum -> sum + result.time end)
      },
      limit: -12
    )
  end

  defp biotope_results(results, attribute) do
    [
      Map.get(results, :vegetation) |> Map.get(attribute),
      Map.get(results, :herbivore) |> Map.get(attribute),
      Map.get(results, :predator) |> Map.get(attribute)
    ]
  end

  defp pubsub_topic(%{"topic" => topic, "data" => data}) do
    [topic, data]
    |> Enum.map_join("_", &String.downcase(&1))
    |> String.to_atom()
  end

  defp attach_telemetry do
    :telemetry.attach_many(
      "monitoring-telemetry-#{inspect(self())}",
      [
        # [:ximula, :sim, :queue, :start],
        [:ximula, :sim, :queue, :stop],
        # [:ximula, :sim, :pipeline, :start],
        [:ximula, :sim, :pipeline, :stop],
        # [:ximula, :sim, :pipeline, :stage, :start],
        [:ximula, :sim, :pipeline, :stage, :stop],
        # [:ximula, :sim, :pipeline, :stage, :entity, :start],
        [:ximula, :sim, :pipeline, :stage, :entity, :stop],
        # [:ximula, :sim, :pipeline, :stage, :step, :start],
        [:ximula, :sim, :pipeline, :stage, :step, :stop]
      ],
      &__MODULE__.handle_telemetry_event/4,
      %{pid: self()}
    )
  end

  defp prepare_sim_stack_chart(socket, chart, opts) do
    socket
    |> prepare_chart(
      chart,
      [
        %{
          label: "Step",
          borderColor: "oklch(79.5% 0.184 86.047)",
          backgroundColor: "rgb(4, 120, 87, 0.8)"
        },
        %{
          label: "Entity",
          borderColor: "oklch(76.5% 0.177 163.223)",
          backgroundColor: "rgb(4, 120, 87, 0.8)"
        },
        %{
          label: "Stage",
          borderColor: "rgb(16, 185, 129, 0.8)",
          backgroundColor: "rgb(4, 120, 87, 0.8)"
        },
        %{
          label: "Pipeline",
          borderColor: "rgb(249, 115, 22, 0.8)",
          backgroundColor: "rgb(194, 65, 12, 0.8)"
        },
        %{
          label: "Queue",
          borderColor: "rgb(241, 65, 94, 0.8)",
          backgroundColor: "rgb(180, 14, 41, 0.8)"
        }
      ],
      opts
    )
  end

  defp prepare_biotope_chart(socket, chart, opts) do
    socket
    |> prepare_chart(
      chart,
      [
        %{
          label: "Vegetation",
          borderColor: "rgb(16, 185, 129, 0.8)",
          backgroundColor: "rgb(4, 120, 87, 0.8)"
        },
        %{
          label: "Herbivore",
          borderColor: "rgb(249, 115, 22, 0.8)",
          backgroundColor: "rgb(194, 65, 12, 0.8)"
        },
        %{
          label: "Predator",
          borderColor: "rgb(241, 65, 94, 0.8)",
          backgroundColor: "rgb(180, 14, 41, 0.8)"
        }
      ],
      opts
    )
  end
end
