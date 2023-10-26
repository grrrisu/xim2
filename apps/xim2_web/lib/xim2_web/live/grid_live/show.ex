defmodule Xim2Web.GridLive.Show do
  use Xim2Web, :live_view

  alias Ximula.Grid

  def mount(_params, _session, socket) do
    grid = Grid.create(50, 25, fn x, y -> x + y end)
    {:ok, assign(socket, grid: grid)}
  end

  def handle_event("update", _, socket) do
    value = Grid.get(socket.assigns.grid, 0, 0)
    socket = assign(socket, grid: Grid.put(socket.assigns.grid, 0, 0, value + 1))
    {:noreply, socket}
  end

  def render(assigns) do
    ~H"""
    <h1>Grid</h1>
    <div class="border border-red-500 bg-red-100">
      <div class="m-2" style="height: 50px">
        <p>Some text before the grid</p>
        <.button phx-click="update">Update</.button>
      </div>
      <.grid :let={{x, y, value}} grid={@grid} width="200vmin" height="100vmin" class="m-6">
        <.cell x={x} y={y} value={value} class="bg-green-300" />
      </.grid>
    </div>
    """
  end

  def grid(assigns) do
    ~H"""
    <div class="overflow-x-auto">
      <.grid_container
        :let={{x, y, value}}
        grid={@grid}
        class={@class}
        style={"width: #{@width}; height: #{@height}"}
      >
        <%= render_slot(@inner_block, {x, y, Grid.get(@grid, x, y)}) %>
      </.grid_container>
    </div>
    """
  end

  # attr :type, :string, default: ""
  def grid_container(assigns) do
    assigns = assign(assigns, width: Grid.width(assigns.grid), height: Grid.height(assigns.grid))

    ~H"""
    <div
      id="grid"
      class={["grid auto-rows-fr bg-gray-300 border-l border-b border-gray-900 h-full w-full", @class]}
      style={[
        "grid-template-columns: repeat(#{@width},1fr); grid-template-rows: repeat(#{@height},1fr);",
        @style
      ]}
    >
      <%= for y <- 0..(@height - 1) do %>
        <%= for x <- 0..(@width - 1) do %>
          <%= render_slot(@inner_block, {x, y, Grid.get(@grid, x, y)}) %>
        <% end %>
      <% end %>
    </div>
    """
  end

  def cell(assigns) do
    assigns = assign(assigns, id: "cell-#{assigns.x}-#{assigns.y}")

    ~H"""
    <div
      id={@id}
      class={["bg-gray-200 border-t border-r border-gray-900 cell", @class]}
      phx-click="toggle-cell"
      phx-value-x={@x}
      phx-value-y={@y}
    >
      <%= # "#{@x}:#{@y}" %>
      <%= # @value %>
    </div>
    """
  end
end
