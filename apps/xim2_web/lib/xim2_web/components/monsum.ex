defmodule Monsum do
  use Phoenix.Component

  import Xim2Web.CoreComponents

  def main_title(assigns) do
    ~H"""
    <h1 class="text-slate-200 text-4xl font-light mb-6"><%= render_slot(@inner_block) %></h1>
    """
  end

  # --- core components modified colors ---

  @doc """
  Renders a back navigation link.

  ## Examples

      <.back navigate={~p"/posts"}>Back to posts</.back>
  """
  attr :navigate, :any, required: true
  slot :inner_block, required: true

  def back(assigns) do
    ~H"""
    <div class="mt-16">
      <.link
        navigate={@navigate}
        class="text-sm font-semibold leading-6 text-sky-300 hover:text-sky-500"
      >
        <.icon name="hero-arrow-left-solid" class="h-3 w-3" />
        <%= render_slot(@inner_block) %>
      </.link>
    </div>
    """
  end
end
