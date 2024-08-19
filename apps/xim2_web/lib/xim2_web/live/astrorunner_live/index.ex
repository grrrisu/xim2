defmodule Xim2Web.AstrorunnerLive.Index do
  use Xim2Web, :live_view

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <.main_title>Astrorunner</.main_title>
    """
  end
end
