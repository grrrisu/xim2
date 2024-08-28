defmodule Xim2Web.AstrorunnerLive.Index do
  alias Phoenix.PubSub
  use Xim2Web, :live_view

  import Xim2Web.ProjectComponents
  import Monsum.BoardgameComponents

  def mount(_params, _session, socket) do
    if connected?(socket) do
      PubSub.subscribe(Xim2.PubSub, "astrorunner")
    end

    {:ok, assign(socket, global_board: global_board())}
  end

  def board_setup?(global_board) do
    !is_nil(global_board.cards)
  end

  def handle_event("setup_board", _params, socket) do
    Astrorunner.setup()
    {:noreply, socket}
  end

  def handle_info({"astrorunner", :setup_done}, socket) do
    {:noreply, assign(socket, global_board: global_board())}
  end

  def render(assigns) do
    ~H"""
    <.main_section title="Astrorunner" back={~p"/"}>
      <%= if board_setup?(@global_board) do %>
        <h2>Arbeitsmarkt</h2>
        <.cards deck={@global_board.cards.pilots} />
        <.cards deck={@global_board.cards.level_2} />
        <.cards deck={@global_board.cards.level_1} />
      <% else %>
        <p class="mb-3">No game available.</p>
        <.button phx-click="setup_board">Setup Board</.button>
      <% end %>
    </.main_section>
    """
  end

  def cards(assigns) do
    ~H"""
    <div class="flex mb-3">
      <.card :for={card <- @deck.revealed} border_class="mr-2">
        <:title><%= card.title %></:title>
        <:picture>
          <.picture small={~p"/images/mountain-searching.avif"} />
        </:picture>
        <:body_title>Title</:body_title>
        <:body>
          <%= card.text %>
        </:body>
      </.card>
    </div>
    """
  end

  defp global_board() do
    Astrorunner.global_board()
  end
end
