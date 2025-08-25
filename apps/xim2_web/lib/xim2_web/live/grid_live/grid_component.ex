defmodule Monsum.GridCompnent do
  use Phoenix.Component

  @moduledoc """
  components to display grids
  """

  @doc """
  Renders a streamed grid wrapped in an overflow div.

  ## Examples

      <.grid
        grid={@streams.grid}
        grid_width={20}
        grid_height={10}
      >
        <:fields :let={{dom_id, %{x: x, y: y, value: value}}}>
          <div>Position [<%= @x %>,<%= y %>]: <%= value %></div>
        </:fields>
        <:layer></:layer>
      </.grid>
  """
  attr :id, :string, default: "grid"
  attr :class, :string, default: ""
  attr :height, :string, default: "100vmin"
  attr :width, :string, default: "100vmin"
  attr :grid, :any, required: true, doc: "stream of cells"
  attr :grid_width, :integer, required: true, doc: "Grid.width(grid)"
  attr :grid_height, :integer, required: true, doc: "Grid.height(grid)"
  slot :fields, required: true, doc: "cells in positioned order"

  slot :layer, required: false, doc: "after the grid within overflow container" do
    attr :items, :list, required: true
    attr :id, :string, required: true
  end

  def grid(assigns) do
    ~H"""
    <div class="overflow-x-auto">
      <div class={["relative", @class]} style={"width: #{@width}; height: #{@height}"}>
        <.grid_container
          :let={{dom_id, cell}}
          id={@id}
          grid={@grid}
          grid_height={@grid_height}
          grid_width={@grid_width}
        >
          {render_slot(@fields, {dom_id, cell})}
        </.grid_container>
        <%= for layer <- @layer do %>
          <div id={layer.id} phx-update="stream" class="absolute top-0 h-full w-full">
            <%= for {dom_id, item} <- layer.items do %>
              {render_slot(layer, {dom_id, item})}
            <% end %>
          </div>
        <% end %>
      </div>
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
  attr :grid_height, :integer, required: true
  attr :grid_width, :integer, required: true
  slot :inner_block, required: true

  def grid_container(assigns) do
    ~H"""
    <div
      id={@id}
      phx-update="stream"
      class="grid auto-rows-fr bg-gray-300 border-l border-b border-gray-900 h-full w-full"
      style={"grid-template-columns: repeat(#{@grid_width},1fr); grid-template-rows: repeat(#{@grid_height},1fr);"}
    >
      <%= for {dom_id, cell} <- @grid do %>
        {render_slot(@inner_block, {dom_id, cell})}
      <% end %>
    </div>
    """
  end
end
