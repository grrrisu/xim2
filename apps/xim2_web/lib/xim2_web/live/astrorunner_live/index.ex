defmodule Xim2Web.AstrorunnerLive.Index do
  use Xim2Web, :live_view

  import Xim2Web.ProjectComponents

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <.main_section title="Astrorunner" back={~p"/"}></.main_section>
    """
  end
end
