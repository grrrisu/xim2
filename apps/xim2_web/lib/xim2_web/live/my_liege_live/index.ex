defmodule Xim2Web.MyLiegeLive.Index do
  alias Phoenix.PubSub
  use Xim2Web, :live_view

  import Xim2Web.ProjectComponents

  def mount(_params, _session, socket) do
    socket = if connected?(socket), do: prepare_realm(socket), else: assign(socket, realm: nil)
    socket = assign(socket, edit_items: [], page_title: "My Liege")
    {:ok, socket}
  end

  def prepare_realm(socket) do
    PubSub.subscribe(Xim2Web.PubSub, "my_liege")
    handle_change(MyLiege.create(), socket)
  end

  def handle_event("change_food", %{"realm" => %{"food" => food}}, socket) do
    food = String.to_integer(food)
    MyLiege.update({[:storage, :food], food})
    {:noreply, assign(socket, form: food_form_data(food))}
  end

  def handle_event("sim_step", %{}, socket) do
    {:noreply, handle_change(MyLiege.sim_step(), socket)}
  end

  def handle_event("create", %{}, socket) do
    {:noreply, assign(socket, realm: MyLiege.create())}
  end

  def handle_event(
        "edit-property",
        %{"property" => property},
        %{assigns: %{edit_items: edit_items}} = socket
      ) do
    {:noreply, assign(socket, edit_items: [String.to_atom(property) | edit_items])}
  end

  def handle_event(
        "change_property",
        %{"realm" => %{"property" => "birth_rate", "value" => "0.4"}},
        socket
      ) do
    {:noreply, socket}
  end

  def handle_change(realm, socket) do
    form = food_form_data(Map.get(realm.storage, :food, 0))
    assign(socket, realm: realm, form: form)
  end

  def handle_info({_sim, _attr, _value} = event, socket) do
    dbg(event)
    {:noreply, socket}
  end

  def handle_info(msg, socket) do
    dbg(msg)
    {:noreply, socket}
  end

  def food_form_data(food) do
    %{"food" => food} |> to_form()
  end

  def render(assigns) do
    ~H"""
    <.main_section title="My Liege" back={~p"/"}>
      <%= if @realm do %>
        <.food_form form={@form} />
        <.population realm={@realm} edit_items={@edit_items} />
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
        <.button class="ml-2" id="button-change">Change</.button>
      </.form>
      <.button class="mt-5 mr-2" phx-click="sim_step" id="button-sim-step">Sim Step</.button>
      <.button class="mt-5" phx-click="create" id="button-recreate">Recreate</.button>
    </.action_box>
    """
  end

  def population(assigns) do
    ~H"""
    <.action_box class="mb-2">
      <.small_title>Population</.small_title>
      <div class="flex gap-x-7">
        <div>
          <.social_stratum social={@realm.working} name="working" />
          <.social_stratum social={@realm.poverty} name="poverty" />
        </div>
        <div>
          <.property_table realm={@realm} edit_items={@edit_items}>
            <:row label="Birthrate" property={:birth_rate} />
            <:row label="Deathrate" property={:death_rate} />
            <:row label="Disease" property={:disease_rate} />
          </.property_table>
        </div>
      </div>
    </.action_box>
    """
  end

  def property_table(assigns) do
    ~H"""
    <table class="">
      <tbody>
        <tr :for={row <- @row}>
          <td><strong><%= row.label %></strong></td>
          <td>
            <.editable_property realm={@realm} property={row.property} edit_items={@edit_items} />
          </td>
        </tr>
      </tbody>
    </table>
    """
  end

  def editable_property(assigns) do
    value = get_in(assigns.realm, List.wrap(assigns.property))
    form = %{"value" => value, "property" => assigns.property} |> to_form()

    assigns =
      assign(assigns,
        value: value,
        form: form,
        edit: Enum.member?(assigns.edit_items, assigns.property)
      )

    ~H"""
    <div class="relative">
      <%= if @edit do %>
        <div class="absolute left-0 -bottom-6 w-32 rounded-md border border-sky-400 py-1 pr-1 bg-sky-800">
          <.form
            :let={form}
            for={@form}
            as={:realm}
            phx-submit="change_property"
            class="flex items-center"
          >
            <.icon name="la-angle-left" class="align-middle" />
            <.input field={form[:property]} value={@property} type="hidden" />
            <.input
              field={form[:value]}
              value={@value}
              size="5"
              input_class="mt-0 py-1 px-2 text-right"
            />
            <.button class="py-1 px-2 ml-2" id="button-change">
              <.icon name="la-upload" />
            </.button>
          </.form>
        </div>
      <% else %>
        <span><%= @value %></span><a href="#" phx-click="edit-property" phx-value-property={@property}> <.icon name="la-edit" /></a>
      <% end %>
    </div>
    """
  end

  def social_stratum(assigns) do
    assigns = assign(assigns, title: String.capitalize(assigns.name))

    ~H"""
    <div class="mb-2" id={"social_stratum_#{@name}"}>
      <strong>
        <.icon name="la-users" class="la-2x align-middle mr-1" /><%= @title %>
      </strong>
      <p>
        <span class="gen_1"><%= @social.gen_1 |> Float.round(2) %></span>
        | <span class="gen_2"><%= @social.gen_2 |> Float.round(2) %></span>
        | <span class="gen_3"><%= @social.gen_3 |> Float.round(2) %></span>
      </p>
    </div>
    """
  end
end
