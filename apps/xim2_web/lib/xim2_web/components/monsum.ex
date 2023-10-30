defmodule Monsum do
  use Phoenix.Component

  import Xim2Web.CoreComponents

  def main_title(assigns) do
    ~H"""
    <h1 class="text-slate-200 text-4xl font-light mb-6"><%= render_slot(@inner_block) %></h1>
    """
  end

  attr :small, :string, required: true, doc: "smaller 768px"
  attr :medium, :string, default: nil, doc: "min 768px"
  attr :large, :string, default: nil, doc: "min 1024px"

  def header_visual(assigns) do
    ~H"""
    <div class="overflow-y-hidden h-[50vh]">
      <picture>
        <%= if @medium do %>
          <source srcset={@medium} media="(min-width: 768px)" />
        <% end %>
        <%= if @large do %>
          <source srcset={@large} media="(min-width: 1024px)" />
        <% end %>
        <img src={@small} class="w-full" />
      </picture>
    </div>
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
