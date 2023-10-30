defmodule Monsum do
  use Phoenix.Component

  def main_title(assigns) do
    ~H"""
    <h1 class="text-sky-100 text-4xl font-light mb-6"><%= render_slot(@inner_block) %></h1>
    """
  end
end
