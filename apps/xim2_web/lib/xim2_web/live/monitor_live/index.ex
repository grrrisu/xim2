defmodule Xim2Web.MonitorLive.Index do
  use Xim2Web, :live_view

  require Logger

  alias Phoenix.PubSub

  alias Sim.Monitor

  @items 500
  @timeout 50_000
  @tasks 500

  def mount(params, _session, socket) do
    if connected?(socket), do: prepare(params)

    {:ok,
     socket
     |> prepare_summary_chart("duration-summary-chart", fill: true)
     |> prepare_summary_chart("ok-summary-chart", fill: false)
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
      <.boxes width="w-1/4">
        <:box>
          <.info_card value={@schedulers} icon="la-microchip" />
        </:box>
        <:box>
          <.info_card value={number_format(@items)} icon="la-cubes" />
        </:box>
        <:box>
          <.info_card value={number_format(@timeout)} icon="la-hourglass-half" />
        </:box>
        <:box>
          <.info_card value={number_format(@tasks)} icon="la-cogs" />
        </:box>
      </.boxes>
      <.boxes :if={@monitor_view} width="w-1/2">
        <:box><.chart name="duration-chart" hook="Monitor" /></:box>
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
        <:box><.chart name="duration-summary-chart" hook="Summary" /></:box>
        <:box><.chart name="ok-summary-chart" hook="Summary" /></:box>
      </.boxes>
      <:footer>
        <.action_box :if={@monitor_view} class="mb-2">
          <.start_button running={@running} />
        </.action_box>
      </:footer>
    </.main_section>
    """
  end

  attr :title, :string
  attr :back, :string
  slot :inner_block, required: true
  slot :footer

  def main_section(assigns) do
    ~H"""
    <section class="flex flex-col">
      <div>
        <.main_title><%= @title %></.main_title>
        <.back navigate={@back}>Home</.back>
      </div>
      <div>
        <%= render_slot(@inner_block) %>
      </div>
      <div><%= render_slot(@footer) %></div>
    </section>
    """
  end

  def boxes(assigns) do
    ~H"""
    <div class="flex flex-row flex-wrap p-2">
      <div :for={box <- @box} class={["flex-auto", @width]}>
        <%= render_slot(box) %>
      </div>
    </div>
    """
  end

  def info_card(assigns) do
    ~H"""
    <div>
      <span class="align-super"><%= @value %></span>
      <.icon name={@icon} class="la-2x" />
    </div>
    """
  end

  def chart(assigns) do
    ~H"""
    <div id={"#{@name}-container"} phx-update="ignore" class="relative">
      <canvas id={"#{@name}"} phx-hook={@hook}></canvas>
    </div>
    """
  end

  def duration_table(assigns) do
    ~H"""
    <table class="table-auto w-full">
      <thead class="text-sky-400">
        <th>Time</th>
        <th>Duration (µm)</th>
        <th>Overhead Queue (µm)</th>
      </thead>
      <tbody
        id="durations"
        phx-update="stream"
        class="divide-y divide-sky-800 border-t border-sky-600 text-sm leading-6 text-sky-300"
      >
        <tr :for={{dom_id, item} <- @durations} id={dom_id}>
          <td class="text-right"><%= Calendar.strftime(item.time, "%H:%M:%S:%f") %></td>
          <td class="text-right"><%= item.duration |> number_format() %></td>
          <td class="text-right">
            <%= (item.duration - @items * @timeout / @tasks) |> number_format() %>
          </td>
        </tr>
      </tbody>
    </table>
    """
  end

  def handle_event("start", _, socket) do
    Logger.info("start sim")
    :ok = Monitor.start()
    {:noreply, socket |> assign(running: true) |> put_flash(:info, "sim queue started")}
  end

  def handle_event("stop", _, socket) do
    Logger.info("stop sim")
    :ok = Monitor.stop()
    {:noreply, socket |> assign(running: false) |> put_flash(:info, "sim queue stopped")}
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
        {namespace, :queue_summary, %{results: results}},
        %{assigns: %{pubsub_topic: namespace}} = socket
      ) do
    {:noreply,
     socket
     |> push_event("update-chart-duration-summary-chart", %{
       x_axis: DateTime.now!("Etc/UTC") |> DateTime.to_iso8601(),
       vegetation: results |> Enum.at(0) |> Map.get(:time),
       herbivore: results |> Enum.at(1) |> Map.get(:time),
       predator: results |> Enum.at(2) |> Map.get(:time)
     })
     |> push_event("update-chart-ok-summary-chart", %{
       x_axis: DateTime.now!("Etc/UTC") |> DateTime.to_iso8601(),
       vegetation: results |> Enum.at(0) |> Map.get(:ok),
       herbivore: results |> Enum.at(1) |> Map.get(:ok),
       predator: results |> Enum.at(2) |> Map.get(:ok)
     })}
  end

  def handle_info({namespace, topic, _payload}, %{private: %{pubsub_topic: namespace}} = socket) do
    Logger.info("received simulation #{namespace} topic #{topic}")
    # dbg(payload)
    {:noreply, socket}
  end

  def handle_info(msg, socket) do
    dbg(msg)
    {:noreply, socket}
  end

  defp number_format(number, precision \\ 0) do
    Number.Delimit.number_to_delimited(number, precision: precision)
  end

  defp prepare(params) when map_size(params) == 0 do
    subscribe(%{"topic" => "Monitor", "data" => "data"})
    prepare_data()
  end

  defp prepare(params) do
    subscribe(params)
  end

  defp prepare_data() do
    Monitor.create_data(@items)
    Monitor.prepare_queues(@timeout, @tasks)
  end

  defp subscribe(%{"topic" => topic, "data" => data}) do
    :ok = PubSub.subscribe(Xim2.PubSub, "#{topic}:#{data}")
  end

  defp pubsub_topic(params) when map_size(params) == 0, do: pubsub_topic(["Monitor", "data"])

  defp pubsub_topic(%{"topic" => topic, "data" => data}), do: pubsub_topic([topic, data])

  defp pubsub_topic(topic) when is_list(topic) do
    topic
    |> Enum.map(&String.downcase(&1))
    |> Enum.join("_")
    |> String.to_atom()
  end

  defp prepare_summary_chart(socket, chart, fill: fill) do
    socket
    |> push_event("init-chart-#{chart}", %{
      datasets: [
        %{
          label: "Vegetation",
          borderColor: "rgb(16, 185, 129, 0.8)",
          backgroundColor: "rgb(4, 120, 87, 0.8)",
          fill: fill,
          lineTension: 0,
          borderWidth: 2
        },
        %{
          label: "Herbivore",
          borderColor: "rgb(249, 115, 22, 0.8)",
          backgroundColor: "rgb(194, 65, 12, 0.8)",
          fill: fill,
          lineTension: 0,
          borderWidth: 2
        },
        %{
          label: "Predator",
          borderColor: "rgb(241, 65, 94, 0.8)",
          backgroundColor: "rgb(180, 14, 41, 0.8)",
          fill: fill,
          lineTension: 0,
          borderWidth: 2
        }
      ]
    })
  end
end
