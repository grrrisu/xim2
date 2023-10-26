defmodule Xim2Web.GridLive.Show do
  use Xim2Web, :live_view

  alias Ximula.Grid

  def mount(_params, _session, socket) do
    value = 1
    grid = Grid.create(20, 10, fn x, y -> value end)

    cells =
      grid
      |> Grid.map(&%{id: "#{&1}-#{&2}", x: &1, y: &2, value: &3})
      |> Enum.sort_by(&{&1.y, &1.x})

    {:ok,
     socket
     |> stream(:grid, cells)
     |> assign(grid_width: Grid.width(grid), grid_height: Grid.height(grid), value: value)}
  end

  def handle_event("update", _, socket) do
    value = socket.assigns.value

    {:noreply,
     socket =
       socket
       |> assign(value: value + 1)
       |> stream_insert(:grid, %{id: "0-0", x: 0, y: 0, value: value + 1})
       |> stream_insert(:grid, %{id: "1-1", x: 1, y: 1, value: value + 1})
       |> stream_insert(:grid, %{id: "2-2", x: 2, y: 2, value: value + 1})}
  end

  def handle_event("replace", _, socket) do
    value = socket.assigns.value

    grid =
      Grid.create(20, 10, fn x, y -> value + 10 end)
      |> Grid.map(&%{id: "#{&1}-#{&2}", x: &1 + 10, y: &2 + 10, value: &3})
      |> Enum.sort_by(&{&1.y, &1.x})

    {:noreply,
     socket =
       socket
       |> assign(value: value + 10)
       |> stream(:grid, grid)}
  end

  def handle_event("bigger", _, socket) do
    value = socket.assigns.value

    grid =
      Grid.create(50, 25, fn x, y -> value + 10 end)
      |> Grid.map(&%{id: "#{&1}-#{&2}", x: &1, y: &2, value: &3})
      |> Enum.sort_by(&{&1.y, &1.x})

    {:noreply,
     socket =
       socket
       |> assign(grid_width: 50, grid_height: 25, value: value + 50)
       |> stream(:grid, grid, reset: true)}
  end

  def handle_event("smaller", _, socket) do
    value = socket.assigns.value

    grid =
      Grid.create(10, 5, fn x, y -> value + 10 end)
      |> Grid.map(&%{id: "#{&1}-#{&2}", x: &1, y: &2, value: &3})
      |> Enum.sort_by(&{&1.y, &1.x})

    {:noreply,
     socket =
       socket
       |> assign(grid_width: 10, grid_height: 5, value: value + 50)
       |> stream(:grid, grid, reset: true)}
  end

  def render(assigns) do
    ~H"""
    <h1>Grid</h1>
    <div class="border border-red-500 bg-red-100">
      <div class="m-2" style="height: 50px">
        <p>Some text before the grid</p>
        <.button phx-click="update">Update</.button>
        <.button phx-click="replace">Replace</.button>
        <.button phx-click="bigger">Bigger</.button>
        <.button phx-click="smaller">Smaller</.button>
      </div>
      <.grid
        :let={{dom_id, %{x: x, y: y, value: value}}}
        grid={@streams.grid}
        grid_height={@grid_height}
        grid_width={@grid_width}
        width="200vmin"
        height="100vmin"
        class="m-6"
      >
        <.cell id={dom_id} x={x} y={y} value={value} class="bg-green-300" />
      </.grid>
    </div>
    """
  end

  def grid(assigns) do
    ~H"""
    <div class="overflow-x-auto">
      <.grid_container
        :let={{dom_id, cell}}
        grid={@grid}
        class={@class}
        grid_height={@grid_height}
        grid_width={@grid_width}
        style={"width: #{@width}; height: #{@height}"}
      >
        <%= render_slot(@inner_block, {dom_id, cell}) %>
      </.grid_container>
    </div>
    """
  end

  # attr :type, :string, default: ""
  def grid_container(assigns) do
    ~H"""
    <div
      id="grid"
      phx-update="stream"
      class={["grid auto-rows-fr bg-gray-300 border-l border-b border-gray-900 h-full w-full", @class]}
      style={[
        "grid-template-columns: repeat(#{@grid_width},1fr); grid-template-rows: repeat(#{@grid_height},1fr);",
        @style
      ]}
    >
      <%= for {dom_id, cell} <- @grid do %>
        <%= render_slot(@inner_block, {dom_id, cell}) %>
      <% end %>
    </div>
    """
  end

  def cell(assigns) do
    ~H"""
    <div
      id={@id}
      class={["bg-gray-200 border-t border-r border-gray-900 cell", @class]}
      phx-click="toggle-cell"
      phx-value-x={@x}
      phx-value-y={@y}
    >
      <%= "#{@x}:#{@y}" %> | <%= @value %>
    </div>
    """
  end
end
