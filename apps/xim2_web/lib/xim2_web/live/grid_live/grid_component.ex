defmodule Xim2Web.GridCompnent do
  use Phoenix.Component

  @doc """
  Renders a streamed grid wrapped in an overflow div.

  ## Examples

      <.grid
        :let={{dom_id, %{x: x, y: y, value: value}}}
        grid={@streams.grid}
        grid_width={20}
        grid_height={10}
      >
        <div>Position [<%= @x %>,<%= y %>]: <%= value %></div>
      </.grid>
  """
  attr :id, :string, default: "grid"
  attr :class, :string, default: ""
  attr :height, :string, default: "100vmin"
  attr :width, :string, default: "100vmin"
  attr :grid, :any, required: true, doc: "stream of cells"
  attr :grid_width, :integer, required: true, doc: "Grid.width(grid)"
  attr :grid_height, :integer, required: true, doc: "Grid.height(grid)"
  slot :inner_block, required: true, doc: "cells in positioned order"

  def grid(assigns) do
    ~H"""
    <div class="overflow-x-auto">
      <.grid_container
        :let={{dom_id, cell}}
        id={@id}
        class={@class}
        style={"width: #{@width}; height: #{@height}"}
        grid={@grid}
        grid_height={@grid_height}
        grid_width={@grid_width}
      >
        <%= render_slot(@inner_block, {dom_id, cell}) %>
      </.grid_container>
    </div>
    """
  end

  @doc """
  Renders a streamed grid without a wrapper.

  ## Examples

      <.grid_container
        :let={{dom_id, %{x: x, y: y, value: value}}}
        grid={@streams.grid}
      >
        <div>Position [<%= @x %>,<%= y %>]: <%= value %></div>
      </.grid_container>

  """
  attr :id, :string, default: "grid"
  attr :grid, :any, required: true, doc: "stream of cells"
  attr :class, :string, default: ""
  attr :style, :string, default: "", doc: "mainly to set the height and width"
  attr :grid_height, :integer, required: true
  attr :grid_width, :integer, required: true
  slot :inner_block, required: true

  def grid_container(assigns) do
    ~H"""
    <div
      id={@id}
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
end
