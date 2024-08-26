defmodule Xim2Web.AstrorunnerLive.Index do
  use Xim2Web, :live_view

  import Xim2Web.ProjectComponents
  import Monsum.BoardgameComponents

  def mount(_params, _session, socket) do
    {:ok, assign(socket, global_board: Astrorunner.global_board())}
  end

  def render(assigns) do
    ~H"""
    <.main_section title="Astrorunner" back={~p"/"}>
      <h2>Arbeitsmarkt</h2>
      <.cards deck={@global_board.cards.level_1} />
    </.main_section>
    """
  end

  def cards(assigns) do
    ~H"""
    <.card :for={card <- @deck}>
      <:title><%= card.title %></:title>
      <:picture>
        <.picture small={~p"/images/mountain-searching.avif"} />
      </:picture>
      <:body_title>Title</:body_title>
      <:body>
        <%= card.text %>
      </:body>
    </.card>
    """
  end
end
