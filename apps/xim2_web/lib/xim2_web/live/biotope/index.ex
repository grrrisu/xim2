defmodule Xim2Web.BiotopeLive.Index do
  use Xim2Web, :live_view

  alias Xim2Web.BiotopeLive.Form

  def mount(_params, _session, socket) do
    {:ok, assign(socket, biotope: Biotope.get())}
  end

  def handle_params(_params, _uri, socket) do
    {:noreply, socket}
  end

  def render(assigns) do
    ~H"""
    <.main_title>Biotope</.main_title>
    <.back navigate={~p"/"}>Home</.back>
    <%= if @biotope do %>
      show grid
    <% else %>
      <.live_component id="biotope-form" module={Form} />
    <% end %>
    """
  end
end
