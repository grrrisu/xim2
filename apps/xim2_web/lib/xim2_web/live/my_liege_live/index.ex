defmodule Xim2Web.MyLiegeLive.Index do
  alias Phoenix.PubSub
  use Xim2Web, :live_view

  import Xim2Web.ProjectComponents

  def mount(_params, _session, socket) do
    socket = if connected?(socket), do: prepare_realm(socket), else: assign(socket, realm: nil)
    {:ok, socket}
  end

  def prepare_realm(socket) do
    PubSub.subscribe(Xim2.PubSub, "my_liege")
    MyLiege.create()
    socket = assign(socket, realm: MyLiege.get_realm())
    form_fields = %{"food" => 0}
    assign(socket, form: to_form(form_fields))
  end

  def handle_event("change_food", %{"realm" => %{"food" => food}}, socket) do
    String.to_integer(food)
    {:noreply, socket}
  end

  def handle_event("sim_step", %{}, socket) do
    {:noreply, assign(socket, realm: MyLiege.sim_step())}
  end

  def handle_event("create", %{}, socket) do
    {:noreply, assign(socket, realm: MyLiege.create())}
  end

  def render(assigns) do
    ~H"""
    <.main_section title="My Liege" back={~p"/"}>
      <%= if @realm do %>
        <.food_form form={@form} />
        <.action_box class="mb-2">
          <h4 class="text-lg mb-2 font-semibold">Population</h4>
          <.social_stratum social={@realm.working} name="Working" />
          <.social_stratum social={@realm.poverty} name="Poverty" />
        </.action_box>
      <% else %>
        <p>Loading...</p>
      <% end %>
    </.main_section>
    """
  end

  def food_form(assigns) do
    ~H"""
    <.action_box class="mb-2">
      <.form :let={form} for={@form} as={:realm} phx-submit="change_food" class="flex items-end">
        <.input field={form[:food]} label="Food" value={form[:food].value} />
        <.button class="ml-2">Change</.button>
      </.form>
      <.button class="mt-5 mr-2" phx-click="sim_step">Sim Step</.button>
      <.button class="mt-5" phx-click="create">Recreate</.button>
    </.action_box>
    """
  end

  def social_stratum(assigns) do
    ~H"""
    <div class="mb-2">
      <strong><.icon name="la-users" class="la-2x align-middle mr-1" /><%= @name %></strong>
      <p>
        <%= @social.gen_1 |> Float.round(2) %> | <%= @social.gen_2 |> Float.round(2) %> | <%= @social.gen_3
        |> Float.round(2) %>
      </p>
    </div>
    """
  end
end
