defmodule Xim2Web.BiotopeLive.Index do
  require Logger
  use Xim2Web, :live_view

  alias Phoenix.PubSub

  alias Ximula.Grid
  alias Xim2Web.BiotopeLive.Form
  import Xim2Web.GridCompnent

  def mount(_params, _session, socket) do
    if connected?(socket) do
      PubSub.subscribe(Xim2.PubSub, "Simulation:biotope")
      Biotope.prepare_sim_queues()
    end

    {:ok, socket}
  end

  def handle_params(_params, _uri, socket) do
    {:noreply, assign_biotope(socket, Biotope.all()) |> assign(running: false)}
  end

  def handle_event("start", _, socket) do
    :ok = Biotope.start()
    {:noreply, assign(socket, running: true)}
  end

  def handle_event("stop", _, socket) do
    :ok = Biotope.stop()
    {:noreply, assign(socket, running: false)}
  end

  def handle_event("reset", _, socket) do
    :ok = Biotope.stop()
    :ok = Biotope.clear()
    {:noreply, assign_biotope(socket, Biotope.all()) |> assign(running: false)}
  end

  def handle_info({:form_submitted, %{width: width, height: height}}, socket) do
    {:ok, biotope} = Biotope.create(width, height)
    {:noreply, assign_biotope(socket, biotope)}
  end

  # we might get events from the previous simulation, after the biotope was reset
  # in this case the event is ignored
  def handle_info({:simulation_biotope, topic, _payload}, %{assigns: %{new: true}} = socket) do
    Logger.warning("received simulation event '#{topic}', but biotope is empty")
    {:noreply, socket}
  end

  def handle_info({:simulation_biotope, :simulation_results, {:vegetation, fields}}, socket) do
    {:noreply, stream(socket, :vegetation, fields |> streamify())}
  end

  def handle_info({:simulation_biotope, :simulation_results, {:herbivore, fields}}, socket) do
    {:noreply,
     socket
     |> stream(
       :vegetation,
       Enum.map(fields, fn {_, change} -> change.vegetation end) |> streamify()
     )
     |> stream(
       :herbivore,
       Enum.map(fields, fn {_, change} -> change.herbivore end) |> streamify()
     )}
  end

  def handle_info({:simulation_biotope, :simulation_errors, {_topic, failed}}, socket) do
    dbg(failed)
    {:noreply, socket}
  end

  def handle_info({:simulation_biotope, topic, _payload}, socket) do
    # dbg(payload)
    Logger.info("received simulation biotop topic #{topic}")
    {:noreply, socket}
  end

  def render(%{new: true} = assigns) do
    ~H"""
    <.main_section>
      <.live_component id="biotope-form" module={Form} />
    </.main_section>
    """
  end

  def render(%{new: false} = assigns) do
    ~H"""
    <.main_section>
      <.action_box class="mb-2">
        <.start_button running={@running} />
        <.reset_button />
      </.action_box>
      <.grid
        id="vegetation"
        grid={@streams.vegetation}
        grid_width={@width}
        grid_height={@height}
        width="1600px"
        height="800px"
        class="mx-auto"
      >
        <:fields :let={{dom_id, %{x: x, y: y, value: value}}}>
          <.field id={dom_id} x={x} y={y} value={value} />
        </:fields>
        <:layer :let={{dom_id, %{value: herbivore}}} id="herbivore" items={@streams.herbivore}>
          <.herbivore id={dom_id} herbivore={herbivore} step={160} />
        </:layer>
      </.grid>
    </.main_section>
    """
  end

  def main_section(assigns) do
    ~H"""
    <section>
      <.main_title>Biotope</.main_title>
      <.back navigate={~p"/"}>Home</.back>
      <p><%= Biotope.get_queues() |> Enum.count() %></p>
      <%= render_slot(@inner_block) %>
    </section>
    """
  end

  def field(assigns) do
    assigns = assign(assigns, size: assigns.value.size |> round())

    ~H"""
    <div id={@id} class="bg-emerald-700 border border-emerald-950">
      <%= @size %>
    </div>
    """
  end

  def herbivore(assigns) do
    {x, y} = assigns.herbivore.position
    assigns = assign(assigns, x: x * assigns.step, y: y * assigns.step)

    ~H"""
    <div
      id={@id}
      class="absolute flex justify-center items-center"
      style={"left: #{@x}px; top: #{@y}px; width: #{@step}px; height: #{@step}px"}
    >
      <span class="bg-sky-500 p-2">
        <%= @herbivore.size %>
      </span>
    </div>
    """
  end

  defp assign_biotope(socket, nil), do: assign(socket, new: true)

  defp assign_biotope(socket, %{vegetation: grid, herbivore: herbivore}) do
    socket
    |> assign_vegetation(grid)
    |> assign_herbivore(herbivore)
  end

  defp assign_vegetation(socket, grid) do
    socket
    |> assign(width: Grid.width(grid), height: Grid.height(grid), new: false)
    |> stream(:vegetation, streamify(Grid.sorted_list(grid)))
  end

  defp assign_herbivore(socket, nil), do: stream(socket, :herbivore, [])

  defp assign_herbivore(socket, herbivore) do
    stream(
      socket,
      :herbivore,
      herbivore
      |> Enum.map(fn {{x, y}, herbivore} ->
        %{id: "#{x}-#{y}", value: herbivore}
      end)
    )
  end

  defp streamify(fields) do
    Enum.map(fields, fn {{x, y}, v} -> %{id: "#{x}-#{y}", x: x, y: y, value: v} end)
  end
end
