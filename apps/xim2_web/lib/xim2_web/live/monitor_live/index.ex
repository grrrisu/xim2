defmodule Xim2Web.MonitorLive.Index do
  use Xim2Web, :live_view

  require Logger

  alias Phoenix.PubSub

  import Xim2Web.Monitor.Components

  @items 500
  @timeout 50_000
  @tasks 500

  def mount(params, _session, socket) do
    if connected?(socket), do: prepare(params)

    {:ok,
     socket
     |> prepare_summary_chart("duration-summary-chart",
       fill: true,
       stacked: true,
       begin_at_zero: true
     )
     |> prepare_summary_chart("ok-summary-chart", fill: false, begin_at_zero: true)
     |> prepare_summary_chart("changed-summary-chart",
       fill: true,
       stacked: true,
       begin_at_zero: true
     )
     |> prepare_summary_chart("errors-summary-chart",
       type: "bar",
       fill: false,
       begin_at_zero: true
     )
     |> assign(
       pubsub_topic: pubsub_topic(params),
       monitor_view: pubsub_topic(params) == :monitor_data,
       running: false,
       schedulers: System.schedulers_online(),
       tasks: @tasks,
       items: @items,
       timeout: @timeout
     )
     |> stream(:durations, [])}
  end

  def render(assigns) do
    ~H"""
    <.main_section title="Sim Monitor" back={~p"/"}>
      <.boxes :if={@monitor_view} width="w-1/2">
        <:box><.chart title="Duration" name="duration-chart" hook="Monitor" /></:box>
        <:box>
          <.duration_table
            durations={@streams.durations}
            items={@items}
            tasks={@tasks}
            timeout={@timeout}
          />
        </:box>
      </.boxes>
      <.boxes :if={!@monitor_view} width="w-1/2">
        <:box><.chart title="Duration" name="duration-summary-chart" hook="Chart" /></:box>
        <:box><.chart title="Items calculated" name="ok-summary-chart" hook="Chart" /></:box>
      </.boxes>
      <.boxes :if={!@monitor_view} width="w-1/2">
        <:box><.chart title="Items changed" name="changed-summary-chart" hook="Chart" /></:box>
        <:box><.chart title="Errors" name="errors-summary-chart" hook="Chart" /></:box>
      </.boxes>
      <:footer>
        <.action_box :if={@monitor_view} class="mb-2">
          <.start_button running={@running} />
        </.action_box>
      </:footer>
    </.main_section>
    """
  end

  def handle_info({:monitor_data, :queue_summary, result}, socket) do
    {:noreply,
     socket
     |> stream_insert(
       :durations,
       Map.put_new(result, :id, System.unique_integer([:positive])),
       limit: -12
     )
     |> push_event("update-duration-chart", %{
       x_axis: DateTime.to_iso8601(result.time),
       duration: result.duration
     })}
  end

  def handle_info(
        {namespace, :simulation_aggregated, results},
        %{assigns: %{pubsub_topic: namespace}} = socket
      ) do
    {:noreply,
     socket
     |> push_chart_data("update-chart-changed-summary-chart", [
       Enum.count(results.vegetation),
       Enum.count(results.herbivore),
       Enum.count(results.predator)
     ])}
  end

  def handle_info(
        {namespace, :queue_summary, %{results: results}},
        %{assigns: %{pubsub_topic: namespace}} = socket
      ) do
    {:noreply,
     socket
     |> push_chart_data("update-chart-duration-summary-chart", biotope_results(results, :time))
     |> push_chart_data("update-chart-ok-summary-chart", biotope_results(results, :ok))
     |> push_chart_data("update-chart-errors-summary-chart", biotope_results(results, :error))}
  end

  def handle_info({namespace, topic, _payload}, %{assigns: %{pubsub_topic: namespace}} = socket) do
    Logger.info("received simulation #{namespace} topic #{topic}")
    # dbg(payload)
    {:noreply, socket}
  end

  def handle_info(msg, socket) do
    Logger.warning("unhandled message #{inspect(msg)}")
    {:noreply, socket}
  end

  defp biotope_results(results, attribute) do
    [
      Map.get(results, :vegetation) |> Map.get(attribute),
      Map.get(results, :herbivore) |> Map.get(attribute),
      Map.get(results, :predator) |> Map.get(attribute)
    ]
  end

  defp prepare(%{"topic" => topic, "data" => data}) do
    :ok = PubSub.subscribe(Xim2.PubSub, "#{topic}:#{data}")
  end

  defp pubsub_topic(%{"topic" => topic, "data" => data}) do
    [topic, data]
    |> Enum.map_join("_", &String.downcase(&1))
    |> String.to_atom()
  end

  defp prepare_summary_chart(socket, chart, opts) do
    socket
    |> push_event("init-chart-#{chart}", %{
      type: opts[:type] || "line",
      options: %{
        stacked: opts[:stacked] || false,
        beginAtZero: opts[:begin_at_zero] || false
      },
      datasets: [
        %{
          label: "Vegetation",
          borderColor: "rgb(16, 185, 129, 0.8)",
          backgroundColor: "rgb(4, 120, 87, 0.8)",
          fill: opts[:fill] || false,
          lineTension: 0,
          borderWidth: 2
        },
        %{
          label: "Herbivore",
          borderColor: "rgb(249, 115, 22, 0.8)",
          backgroundColor: "rgb(194, 65, 12, 0.8)",
          fill: opts[:fill] || false,
          lineTension: 0,
          borderWidth: 2
        },
        %{
          label: "Predator",
          borderColor: "rgb(241, 65, 94, 0.8)",
          backgroundColor: "rgb(180, 14, 41, 0.8)",
          fill: opts[:fill] || false,
          lineTension: 0,
          borderWidth: 2
        }
      ]
    })
  end
end
