defmodule Xim2Web.ComponentLive.Index do
  use Xim2Web, :live_view

  alias Ecto.Changeset

  import Monsum
  import Monsum.BoardgameComponents
  import Monsum.GridCompnent
  import Xim2Web.ProjectComponents

  def mount(_session, _params, socket) do
    {:ok,
     socket
     |> assign(
       page_title: "Components",
       components: "monsum",
       changeset: prepare_changeset(),
       grid: prepare_grid(),
       top_cards: ["A", "B", "C", "D", "E"],
       bottom_cards: []
     )
     |> stream(:grid, prepare_grid())}
  end

  @spec handle_event(<<_::88, _::_*48>>, map(), map()) :: {:noreply, any()}
  def handle_event("change-components", %{"components" => components}, socket) do
    {:noreply, socket |> assign(:components, components) |> stream(:grid, prepare_grid())}
  end

  def handle_event(
        "remove-card",
        %{"index" => index},
        %{assigns: %{top_cards: cards, bottom_cards: bottom_cards}} = socket
      ) do
    cards = List.delete_at(cards, index)
    {:noreply, socket |> assign(top_cards: cards, bottom_cards: [index | bottom_cards])}
  end

  def render(assigns) do
    ~H"""
    <.main_section title="Components" back={~p"/"}>
      <div class="flex">
        <a phx-click="change-components" phx-value-components="monsum" class="mr-4" href="#">
          Monsum
        </a>
        <a phx-click="change-components" phx-value-components="grid" class="mr-4" href="#">Grid</a>
        <a phx-click="change-components" phx-value-components="boardgame" class="mr-4" href="#">
          Boardgame
        </a>
        <a phx-click="change-components" phx-value-components="project" class="mr-4" href="#">
          Project
        </a>
        <a phx-click="change-components" phx-value-components="transition" class="mr-4" href="#">
          Transitions
        </a>
      </div>
      <.monsum_components :if={@components == "monsum"} changeset={@changeset} />
      <.project_components :if={@components == "project"} />
      <.grid_components :if={@components == "grid"} grid={@streams.grid} />
      <.boardgame_components :if={@components == "boardgame"} />
      <.transition_components
        :if={@components == "transition"}
        top_cards={@top_cards}
        bottom_cards={@bottom_cards}
      />
    </.main_section>
    """
  end

  def monsum_components(assigns) do
    ~H"""
    <.flexbox_col class="border border-gray-500 w-full min-h-screen">
      <div>
        <h3>flexbox_col</h3>
        <.flexbox_col>
          <div class="bg-sky-500 text-center">One</div>
          <div class="bg-sky-500 text-center">Two</div>
          <div class="bg-sky-500 text-center">Three</div>
        </.flexbox_col>
      </div>
      <div>
        <h3>boxes</h3>
        <.boxes>
          <:box>
            <div class="bg-sky-500 text-center">One</div>
          </:box>
          <:box>
            <div class="bg-sky-500 text-center">Two</div>
          </:box>
          <:box>
            <div class="bg-sky-500 text-center">Three</div>
          </:box>
          <:box>
            <div class="bg-sky-500 text-center">Four</div>
          </:box>
        </.boxes>
      </div>
      <div>
        <h3>main_title</h3>
        <.main_title>Main Title</.main_title>
      </div>
      <div>
        <h3>title</h3>
        <.title>Title</.title>
      </div>
      <div>
        <h3>sub_title</h3>
        <.sub_title>Sub Title</.sub_title>
      </div>
      <div>
        <h3>small_title</h3>
        <.small_title>Small Title</.small_title>
      </div>
      <div>
        <h3>back</h3>
        <.back navigate={~p"/"}>Back</.back>
      </div>
      <div>
        <h3>button</h3>
        <.button>Send!</.button>
      </div>
      <div>
        <h3>picture</h3>
        <div>
          <.picture
            small={~p"/images/mountain-searching.avif"}
            medium={~p"/images/earth-searching.avif"}
            large={~p"/images/water-searching.jpg"}
            class="mx-auto max-h-40"
          />
        </div>
      </div>
      <div>
        <h3>hero_card</h3>
        <.hero_card link={~p"/components"} class="mb-6 mx-3 basis-1/5">
          <:icon><.icon name="la-window-restore" class="la-2x" /></:icon>
          <:title>Components</:title>
          Monsum and project components
        </.hero_card>
      </div>
      <div>
        <h3>info_card</h3>
        <.info_card value="888" icon="la-cubes" />
      </div>
      <div>
        <h3>action_box with start_button and reset_button</h3>
        <.action_box class="mb-2">
          <.start_button running={false} />
          <.reset_button />
        </.action_box>
      </div>
      <div>
        <h3>Form</h3>
        <.form :let={form} for={@changeset} as={:user}>
          <.input field={form[:name]} label="Name" />
          <.input field={form[:email]} label="E-Mail" />
          <%!-- <.input field={form[:bio]} type="textarea" label="Bio" /> --%>
        </.form>
      </div>
    </.flexbox_col>
    """
  end

  def project_components(assigns) do
    ~H"""
    <.flexbox_col class="border border-gray-500 w-full min-h-screen">
      <div>
        <h3>main_section</h3>
        <.main_section title="Main Title" back={~p"/"}>
          <div class="bg-sky-500 text-center">Main Section</div>
          <:footer>
            <div class="bg-sky-500 text-center">Footer</div>
          </:footer>
        </.main_section>
      </div>
    </.flexbox_col>

    <.flexbox_col class="border border-gray-500 w-full min-h-screen">
      <div>
        <h3>main_box</h3>
        <.main_box>
          <:header>Header</:header>
          <div class="bg-sky-500 text-center">One</div>
          <div class="bg-sky-500 text-center">Two</div>
          <div class="bg-sky-500 text-center">Three</div>
        </.main_box>
      </div>
    </.flexbox_col>
    """
  end

  def grid_components(assigns) do
    ~H"""
    <.flexbox_col class="border border-gray-500 w-full min-h-screen">
      <div>
        <h3>grid</h3>
        <.grid grid={@grid} grid_width={5} grid_height={5}>
          <:fields :let={{dom_id, %{x: x, y: y, value: value}}}>
            <div
              id={dom_id}
              class="text-slate-900 text-center content-center border-t border-r border-gray-900"
            >
              Position [<%= x %>,<%= y %>]: <%= value %>
            </div>
          </:fields>
        </.grid>
      </div>
    </.flexbox_col>
    """
  end

  def boardgame_components(assigns) do
    ~H"""
    <.flexbox_col class="border border-gray-500 w-full min-h-screen">
      <h3>card</h3>
      <.card>
        <:title>Card Title</:title>
        <:picture>
          <.picture small={~p"/images/mountain-searching.avif"} />
        </:picture>
        <:body_title>Title</:body_title>
        <:body>
          Card Body
        </:body>
      </.card>
    </.flexbox_col>
    """
  end

  def transition_components(assigns) do
    ~H"""
    <.flexbox_col class="border border-gray-500 w-full min-h-screen">
      <h3>Card Transitions</h3>
      <p>card_slide_in() and card_fade_out()</p>
      <div class="flex">
        <.anibox :for={{card, index} <- Enum.with_index(@top_cards)} index={index} name="top">
          <span class="text-xl text-slate-950"><%= card %></span>
        </.anibox>
      </div>
      <div class="flex">
        <.anibox :for={{card, index} <- Enum.with_index(@bottom_cards)} index={index} name="bottom">
          <span class="text-xl text-slate-950"><%= card %></span>
        </.anibox>
      </div>
    </.flexbox_col>
    """
  end

  defp anibox(assigns) do
    ~H"""
    <div
      id={"card-#{@name}-#{@index}"}
      phx-mounted={card_slide_in()}
      phx-remove={card_fade_out()}
      phx-click={JS.push("remove-card", value: %{index: @index})}
      class="relative h-40 w-32 text-center border border-gray-500 bg-sky-200 mr-4"
    >
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  defp prepare_changeset() do
    {%{email: "dead@pool.com", name: "Deadpool"}, %{name: :string, email: :string, bio: :string}}
    |> Changeset.change(email: "dead@@@@@pool.com")
    |> Changeset.add_error(:email, "invalid mail address")
    |> to_form(action: :insert, as: :user)
  end

  defp prepare_grid() do
    Enum.flat_map(0..4, fn y ->
      Enum.map(0..4, fn x ->
        %{id: "#{x}-#{y}", x: x, y: y, value: x + y}
      end)
    end)
  end
end
