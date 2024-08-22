defmodule Xim2Web.GridLive.Show do
  use Xim2Web, :live_view

  alias Ximula.Grid

  import Xim2Web.ProjectComponents
  import Xim2Web.GridCompnent

  def mount(_params, _session, socket) do
    value = 1
    grid = Grid.create(20, 10, fn _x, _y -> value end)

    {:ok,
     socket
     |> stream(:grid, streamify(grid))
     |> assign(:page_title, "Grid")
     |> assign(grid_width: Grid.width(grid), grid_height: Grid.height(grid), value: value)}
  end

  def handle_event("update", _, socket) do
    value = socket.assigns.value

    {:noreply,
     socket
     |> assign(value: value + 1)
     |> stream_insert(:grid, %{id: "0-0", x: 0, y: 0, value: value + 1})
     |> stream_insert(:grid, %{id: "1-1", x: 1, y: 1, value: value + 1})
     |> stream_insert(:grid, %{id: "2-2", x: 2, y: 2, value: value + 1})}
  end

  def handle_event("replace", _, socket) do
    value = socket.assigns.value
    grid = Grid.create(20, 10, fn _x, _y -> value + 10 end)

    {:noreply,
     socket
     |> assign(value: value + 10)
     |> stream(:grid, streamify(grid))}
  end

  def handle_event("bigger", _, socket) do
    value = socket.assigns.value
    grid = Grid.create(50, 25, fn _x, _y -> value + 10 end)

    {:noreply,
     socket
     |> assign(grid_width: 50, grid_height: 25, value: value + 50)
     |> stream(:grid, streamify(grid), reset: true)}
  end

  def handle_event("smaller", _, socket) do
    value = socket.assigns.value
    grid = Grid.create(10, 5, fn _x, _y -> value + 10 end)

    {:noreply,
     socket
     |> assign(grid_width: 10, grid_height: 5, value: value + 50)
     |> stream(:grid, streamify(grid), reset: true)}
  end

  defp streamify(grid) do
    grid
    |> Grid.sorted_list()
    |> Enum.map(fn {{x, y}, v} -> %{id: "#{x}-#{y}", x: x, y: y, value: v} end)
  end

  def render(assigns) do
    ~H"""
    <.main_section title="Grid" back={~p"/"}>
      <div class="border border-red-500 text-slate-900 bg-red-100">
        <div class="m-2">
          <p>Some text before the grid</p>
          <.button phx-click="update">Update</.button>
          <.button phx-click="replace">Replace</.button>
          <.button phx-click="bigger">Bigger</.button>
          <.button phx-click="smaller">Smaller</.button>
        </div>
        <.grid
          grid={@streams.grid}
          grid_height={@grid_height}
          grid_width={@grid_width}
          width="200vmin"
          height="100vmin"
          class="m-6"
        >
          <:fields :let={{dom_id, %{x: x, y: y, value: value}}}>
            <.field id={dom_id} x={x} y={y} value={value} class="bg-green-300" />
          </:fields>
        </.grid>
      </div>
    </.main_section>
    """
  end

  def field(assigns) do
    ~H"""
    <div
      id={@id}
      class={["text-xs text-slate-900 bg-gray-200 border-t border-r border-gray-900 cell", @class]}
    >
      <%= "#{@x}:#{@y}" %> | <%= @value %>
    </div>
    """
  end
end
