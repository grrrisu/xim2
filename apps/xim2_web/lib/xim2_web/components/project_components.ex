defmodule Xim2Web.ProjectComponents do
  @moduledoc """
  Xim2 specific components.
  """
  use Phoenix.Component

  import Monsum

  attr :title, :string, default: nil, doc: "Page Title"
  attr :back, :string, default: nil, doc: "~p\"/path/to/parent\""
  slot :inner_block, required: true
  slot :footer, default: nil

  def main_section(assigns) do
    ~H"""
    <.flexbox_col>
      <div>
        <.main_title><%= @title %></.main_title>
        <.back navigate={@back} class="mt-16">Home</.back>
      </div>
      <div>
        <%= render_slot(@inner_block) %>
      </div>
      <div><%= render_slot(@footer) %></div>
    </.flexbox_col>
    """
  end
end
