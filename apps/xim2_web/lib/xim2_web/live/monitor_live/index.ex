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

    {:ok, socket |> assign(:running, false)}
  end

  def render(assigns) do
    ~H"""
    <.main_section title="Sim Monitor" back={~p"/"}>
      <.action_box class="mb-2">
        <.start_button running={@running} />
      </.action_box>
    </.main_section>
    """
  end

  attr :title, :string
  attr :back, :string
  slot :inner_block, required: true

  def main_section(assigns) do
    ~H"""
    <section>
      <.main_title><%= @title %></.main_title>
      <.back navigate={@back}>Home</.back>
      <%= render_slot(@inner_block) %>
    </section>
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

  defp prepare() do
    Monitor.create_data(100)
    Monitor.prepare_queues()
  end
end
