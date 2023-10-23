defmodule Xim2Web.GridLive.Show do
  use Xim2Web, :live_view

  alias Ximula.Grid

  def mount(_params, _session, socket) do
    grid = Grid.create(20, 10, fn x, y -> x + y end)
    {:ok, assign(socket, grid: grid)}
  end

  def render(assigns) do
    ~H"""
    <h1>Grid</h1>
      <div class="overflow-x-auto border border-red-500 bg-red-100">
        <div style="height: 50px">Some text before the grid</div>
        <.grid :let={{x, y, value}} grid={@grid} class="m-6" style="width: 200vmin; height: 100vmin">
          <.cell x={x} y={y} value={value} class="bg-green-300" />
        </.grid>
      </div>
    """
  end

  # attr :type, :string, default: ""
  def grid(assigns) do
    assigns = assign(assigns, width: Grid.width(assigns.grid), height: Grid.height(assigns.grid))

    ~H"""
    <div
      id="grid"
      class={["grid auto-rows-fr bg-gray-300 border-l border-b border-gray-900 h-full w-full", @class]}
      style={["grid-template-columns: repeat(#{@width},1fr); grid-template-rows: repeat(#{@height},1fr);", @style]}
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
    ~H"""
    <div
      id={"cell-#{@x}-#{@y}"}
      class={["bg-gray-200 border-t border-r border-gray-900 cell", @class]}
      phx-click="toggle-cell"
      phx-value-x={@x}
      phx-value-y={@y}
    >
      <%= "#{@x}:#{@y}" %>
      <%=# @value %>
    </div>
    """
  end
end
