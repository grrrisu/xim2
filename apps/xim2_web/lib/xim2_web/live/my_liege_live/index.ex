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
    food = String.to_integer(food)
    {:noreply, socket}
  end

  def render(assigns) do
    ~H"""
    <.main_section title="My Liege" back={~p"/"}>
      <%= if @realm do %>
        <.food_form form={@form} />
        <.social_stratum social={@realm.working} name="Working" />
        <.social_stratum social={@realm.poverty} name="Poverty" />
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
        <.input field={form[:food]} label="Food" />
        <.button class="ml-2 h-10">Change</.button>
      </.form>
    </.action_box>
    """
  end

  def social_stratum(assigns) do
    ~H"""
    <.action_box class="mb-2">
      <strong><.icon name="la-users" class="la-2x align-middle mr-1" /><%= @name %></strong>
      <p>
        <%= @social.gen_1 %> | <%= @social.gen_2 %> | <%= @social.gen_3 %>
      </p>
    </.action_box>
    """
  end
end
