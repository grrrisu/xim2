defmodule Xim2Web.MonitorLive.Index do
  use Xim2Web, :live_view

  require Logger

  alias Phoenix.PubSub

  alias Sim.Monitor

  def mount(_params, _session, socket) do
    if connected?(socket) do
      PubSub.subscribe(Xim2.PubSub, "Monitor:data")
      prepare()
    end

    {:ok,
     socket
     |> assign(
       running: false,
       schedulers: System.schedulers_online(),
       items: 100,
       timeout: 50_000
     )
     |> stream(:durations, [])}
  end

  def render(assigns) do
    ~H"""
    <.main_section title="Sim Monitor" back={~p"/"}>
      <.boxes>
        <:box>
          <span class="align-super"><%= @schedulers %></span>
          <.icon name="la-microchip" class="la-2x" />
        </:box>
        <:box>
          <span class="align-super"><%= @items %></span>
          <.icon name="la-hashtag" class="la-2x" />
        </:box>
      </.boxes>
      <.boxes>
        <:box><.duration_chart /></:box>
        <:box>
          <.duration_table
            durations={@streams.durations}
            items={@items}
            schedulers={@schedulers}
            timeout={@timeout}
          />
        </:box>
      </.boxes>
      <:footer>
        <.action_box class="mb-2">
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
      <div :for={box <- @box} class="flex-auto w-1/2">
        <%= render_slot(box) %>
      </div>
    </div>
    """
  end

  def duration_chart(assigns) do
    ~H"""
    <div id="duration-chart" phx-update="ignore" class="relative">
      <canvas id="duration-chart-canvas" phx-hook="Monitor"></canvas>
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
        <th>Overhead/Item (µm)</th>
      </thead>
      <tbody
        id="durations"
        phx-update="stream"
        class="divide-y divide-sky-800 border-t border-sky-600 text-sm leading-6 text-sky-300"
      >
        <tr :for={{dom_id, item} <- @durations} id={dom_id}>
          <td class="text-right"><%= Calendar.strftime(item.time, "%H:%M:%S:%f") %></td>
          <td class="text-right"><%= item.duration |> number_format(0) %></td>
          <td class="text-right">
            <%= (item.duration - @timeout * @items / @schedulers) |> number_format(2) %>
          </td>
          <td class="text-right">
            <%= ((item.duration - @timeout * @items / @schedulers) / @items) |> number_format(2) %>
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

  def handle_info({:queue_summary, result}, socket) do
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

  defp number_format(number, precision) do
    Number.Delimit.number_to_delimited(number, precision: precision)
  end

  defp prepare() do
    Monitor.create_data(100)
    Monitor.prepare_queues()
  end
end
