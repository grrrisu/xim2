defmodule Xim2Web.BiotopeLive.Index do
  use Xim2Web, :live_view

  alias Phoenix.PubSub

  alias Ximula.Grid
  alias Xim2Web.BiotopeLive.Form
  import Xim2Web.GridCompnent

  def mount(_params, _session, socket) do
    if connected?(socket) do
      PubSub.subscribe(Xim2.PubSub, "Biotope:simulation")
      Biotope.prepare_sim_queues()
    end

    {:ok, socket}
  end

  def handle_params(_params, _uri, socket) do
    {:noreply, assign_biotope(socket, Biotope.get()) |> assign(running: false)}
  end

  def handle_event("start", _, socket) do
    :ok = Biotope.start()
    {:noreply, assign(socket, running: true)}
  end

  def handle_event("stop", _, socket) do
    :ok = Biotope.stop()
    {:noreply, assign(socket, running: false)}
  end

  def handle_info({:form_submitted, %{width: width, height: height}}, socket) do
    {:ok, biotope} = Biotope.create(width, height)
    {:noreply, assign_biotope(socket, biotope.vegetation)}
  end

  def handle_info(%{simulation: Biotope.Sim.Vegetation, changed: _}, socket) do
    {:noreply, stream(socket, :grid, Biotope.get() |> streamify())}
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
      <.start_button running={@running} />
      <.grid
        :let={{dom_id, %{x: x, y: y, value: value}}}
        grid={@streams.grid}
        grid_width={@width}
        grid_height={@height}
      >
        <div id={dom_id} class="bg-emerald-800">
          Position [<%= x %>,<%= y %>]: <%= value.size %>
        </div>
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

  defp assign_biotope(socket, nil), do: assign(socket, new: true)

  defp assign_biotope(socket, grid) do
    socket
    |> assign(width: Grid.width(grid), height: Grid.height(grid), new: false)
    |> stream(:grid, streamify(grid))
  end

  defp streamify(grid) do
    grid
    |> Grid.sorted_list()
    |> Enum.map(fn {{x, y}, v} -> %{id: "#{x}-#{y}", x: x, y: y, value: v} end)
  end
end
