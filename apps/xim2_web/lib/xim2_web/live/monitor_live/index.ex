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

    {:ok, socket |> assign(:running, false) |> stream(:durations, [])}
  end

  def render(assigns) do
    ~H"""
    <.main_section title="Sim Monitor" back={~p"/"}>
      <div class="flex flex-row">
        <div id="duration-chart" phx-update="ignore" class="relative flex-auto w-1/2">
          <canvas id="duration-chart-canvas" phx-hook="Monitor"></canvas>
        </div>
        <div class="flex-auto w-1/2" style="height: 30vh">
          <.duration_table durations={@streams.durations} />
        </div>
      </div>
      <.action_box class="mb-2">
        <.start_button running={@running} />
      </.action_box>
    </.main_section>
    """
  end

  attr :title, :string
  attr :back, :string
  slot :inner_block, required: true

  @spec main_section(map()) :: Phoenix.LiveView.Rendered.t()
  def main_section(assigns) do
    ~H"""
    <section>
      <.main_title><%= @title %></.main_title>
      <.back navigate={@back}>Home</.back>
      <%= render_slot(@inner_block) %>
    </section>
    """
  end

  def duration_table(assigns) do
    ~H"""
    <table>
      <thead>
        <th>Time</th>
        <th>Duration</th>
      </thead>
      <tbody id="durations" phx-update="stream">
        <tr :for={{dom_id, item} <- @durations} id={dom_id}>
          <td><%= item.time %></td>
          <td><%= item.duration %> µm</td>
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
       limit: -10
     )
     |> push_event("update-duration-chart", %{
       x_axis: DateTime.to_iso8601(result.time),
       duration: result.duration
     })}
  end

  defp prepare() do
    Monitor.create_data(100)
    Monitor.prepare_queues()
  end
end
