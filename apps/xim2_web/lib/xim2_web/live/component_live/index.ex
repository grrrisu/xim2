defmodule Xim2Web.ComponentLive.Index do
  use Xim2Web, :live_view

  alias Ecto.Changeset

  import Monsum
  import Xim2Web.ProjectComponents
  import Xim2Web.GridCompnent

  def mount(_session, _params, socket) do
    {:ok,
     socket
     |> assign(
       page_title: "Components",
       components: "monsum",
       changeset: prepare_changeset(),
       grid: prepare_grid()
     )
     |> stream(:grid, prepare_grid())}
  end

  def handle_event("change-components", %{"components" => components}, socket) do
    {:noreply, socket |> assign(:components, components) |> stream(:grid, prepare_grid())}
  end

  def render(assigns) do
    ~H"""
    <.main_section title="Components" back={~p"/"}>
      <div class="flex">
        <a phx-click="change-components" phx-value-components="monsum" class="mr-4" href="#">
          Monsum
        </a>
        <a phx-click="change-components" phx-value-components="project" class="mr-4" href="#">
          Project
        </a>
        <a phx-click="change-components" phx-value-components="grid" class="mr-4" href="#">Grid</a>
      </div>
      <.monsum_components :if={@components == "monsum"} changeset={@changeset} />
      <.project_components :if={@components == "project"} />
      <.grid_components :if={@components == "grid"} grid={@streams.grid} />
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
        <h3>main_title</h3>
        <.main_title>Main Title</.main_title>
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
