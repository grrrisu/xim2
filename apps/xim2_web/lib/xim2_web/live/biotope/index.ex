defmodule Xim2Web.BiotopeLive.Index do
  use Xim2Web, :live_view

  alias Ximula.Grid
  alias Xim2Web.BiotopeLive.Form
  import Xim2Web.GridCompnent

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def handle_params(_params, _uri, socket) do
    {:noreply, assign_biotope(socket, Biotope.get())}
  end

  def handle_info({:form_submitted, %{width: width, height: height}}, socket) do
    {:ok, biotope} = Biotope.create(width, height)
    {:noreply, assign_biotope(socket, biotope)}
  end

  def render(assigns) do
    ~H"""
    <.main_title>Biotope</.main_title>
    <.back navigate={~p"/"}>Home</.back>
    <%= if @new do %>
      <.live_component id="biotope-form" module={Form} />
    <% else %>
      <.grid
        :let={{dom_id, %{x: x, y: y, value: value}}}
        grid={@streams.grid}
        grid_width={@width}
        grid_height={@height}
      >
        <div id={dom_id} class="bg-emerald-800">
          Position [<%= x %>,<%= y %>]: <%= value.vegetation.size %>
        </div>
      </.grid>
    <% end %>
    """
  end

  defp assign_biotope(socket, nil), do: assign(socket, new: true)

  defp assign_biotope(socket, grid) do
    socket
    |> assign(width: Grid.width(grid), height: Grid.height(grid), new: false)
    |> stream(:grid, streamify(grid))
  end

  defp streamify(nil), do: nil

  defp streamify(grid) do
    grid
    |> Grid.sorted_list()
    |> Enum.map(fn {x, y, v} -> %{id: "#{x}-#{y}", x: x, y: y, value: v} end)
  end
end
