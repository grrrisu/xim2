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

  defp global_board() do
    Astrorunner.global_board()
  end

  def handle_event("setup_board", _params, socket) do
    Astrorunner.setup()
    {:noreply, socket}
  end

  def handle_event("select-card", %{"card" => value}, socket) do
    res =
      value
      |> String.split("-")
      |> then(fn [name, index] ->
        [name: String.to_atom(name), index: String.to_integer(index), player: "me"]
      end)
      |> Astrorunner.take_revealed_card()

    case res do
      {:error, msg} -> {:noreply, put_flash(socket, :error, msg)}
      _deck -> assign(socket, global_board: global_board())
    end
  end

  def handle_info(:setup_done, socket) do
    {:noreply, assign(socket, global_board: global_board())}
  end

  def board_setup?(global_board) do
    !is_nil(global_board.cards)
  end

  def render(assigns) do
    ~H"""
    <.main_section title="Astrorunner" back={~p"/"}>
      <%= if board_setup?(@global_board) do %>
        <.job_market cards={@global_board.cards} />
        <.button phx-click="setup_board" data-confirm="Are you sure?">Reset Board</.button>
      <% else %>
        <p class="mb-3">No game available.</p>
        <.button phx-click="setup_board">Setup Board</.button>
      <% end %>
    </.main_section>
    """
  end

  def job_market(assigns) do
    ~H"""
    <div class="mb-5">
      <.sub_title>Arbeitsmarkt</.sub_title>
      <.cards name="pilots" deck={@cards.pilots} />
      <.cards name="level_2" deck={@cards.level_2} />
      <.cards name="level_1" deck={@cards.level_1} />
    </div>
    """
  end

  def cards(assigns) do
    ~H"""
    <div class="flex mb-3">
      <.card
        :for={{card, index} <- Enum.with_index(@deck.revealed)}
        border_class="mr-2"
        click="select-card"
        card_value={"#{@name}-#{index}"}
      >
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
end
