defmodule Xim2Web.ProjectComponents do
  @moduledoc """
  Xim2 specific components.
  """
  use Phoenix.Component

  import Monsum

  attr :title, :string, default: nil, doc: "Page Title"
  attr :back, :string, default: nil, doc: "~p\"/path/to/parent\""
  attr :back_title, :string, default: "Home"
  slot :inner_block, required: true
  slot :footer, default: nil

  def main_section(assigns) do
    ~H"""
    <.flexbox_col>
      <div>
        <.main_title><%= @title %></.main_title>
        <.back navigate={@back} class="mt-16"><%= @back_title %></.back>
      </div>
      <div>
        <%= render_slot(@inner_block) %>
      </div>
      <div><%= render_slot(@footer) %></div>
    </.flexbox_col>
    """
  end

  attr :class, :string, default: ""
  slot :header, required: false
  slot :inner_block, required: true

  def main_box(assigns) do
    ~H"""
    <div class={[
      "p-6 rounded-t-lg drop-shadow-2xl bg-sky-950 border-2 border-sky-500",
      @class
    ]}>
      <div>
        <%= render_slot(@header) %>
      </div>
      <div class="flex flex-wrap place-content-evenly items-stretch">
        <%= render_slot(@inner_block) %>
      </div>
    </div>
    """
  end
end
