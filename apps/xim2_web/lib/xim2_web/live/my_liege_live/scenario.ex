defmodule Xim2Web.MyLiegeLive.Scenario do
  alias Phoenix.PubSub
  use Xim2Web, :live_view

  import Xim2Web.ProjectComponents
  import Xim2Web.Monitor.Components

  def mount(params, _session, socket) do
    dbg(params)
    socket = if connected?(socket), do: prepare_realm(socket), else: assign(socket, realm: nil)

    {:ok,
     socket
     |> assign(edit_items: [], page_title: "My Liege")
     |> prepare_summary_chart("population-history-chart",
       begin_at_zero: true
     )}
  end

  def prepare_realm(socket) do
    PubSub.subscribe(Xim2Web.PubSub, "my_liege")
    handle_change(MyLiege.create(), socket)
  end

  def handle_event("sim_step", %{}, socket) do
    :ok = MyLiege.sim_step()
    {:noreply, socket}
  end

  def handle_event("create", %{}, socket) do
    {:noreply, assign(socket, realm: MyLiege.create())}
  end

  def handle_event(
        "edit_property",
        %{"property" => property},
        %{assigns: %{edit_items: edit_items}} = socket
      ) do
    {:noreply, assign(socket, edit_items: [property | edit_items])}
  end

  def handle_event(
        "change_property",
        %{"realm" => %{"property" => property, "value" => value}},
        %{assigns: %{edit_items: edit_items}} = socket
      ) do
    MyLiege.update({property, value})

    {:noreply,
     assign(socket, realm: MyLiege.get_realm(), edit_items: List.delete(edit_items, property))}
  end

  def handle_change(realm, socket) do
    assign(socket, realm: realm)
  end

  def handle_info({:realm_updated, realm}, socket) do
    {:noreply, assign(socket, realm: realm)}
  end

  def handle_info({_sim, _attr, _value} = _event, socket) do
    # dbg(event)
    {:noreply, socket}
  end

  def handle_info(_msg, socket) do
    # dbg(msg)
    {:noreply, socket}
  end

  def property_form(property, value) do
    %{"value" => value, "property" => property} |> to_form()
  end

  def render(assigns) do
    ~H"""
    <.main_section title="My Liege" back={~p"/my_liege"} back_title="Scenarios">
      <%= if @realm do %>
        <div class="flex flex-row">
          <div>
            <.storage realm={@realm} edit_items={@edit_items} />
            <.population realm={@realm} edit_items={@edit_items} />
          </div>
          <div>
            <.action_box class="ml-2">
              <.small_title>
                <.icon name="la-chart-line" class="la-2x align-bottom mr-1" />Statistics
              </.small_title>
              <.chart title="Population" name="population-history-chart" />
            </.action_box>
          </div>
        </div>
        <.actions />
      <% else %>
        <p>Loading...</p>
      <% end %>
    </.main_section>
    """
  end

  def storage(assigns) do
    ~H"""
    <.action_box class="mb-2">
      <.small_title>
        <.icon name="la-warehouse" class="la-2x align-bottom mr-1" />Storage
      </.small_title>
      <.property_table realm={@realm} edit_items={@edit_items}>
        <:row label="Food" property="storage.food" />
      </.property_table>
    </.action_box>
    """
  end

  def actions(assigns) do
    ~H"""
    <.action_box>
      <.button class="mr-2" phx-click="sim_step" id="button-sim-step">Sim Step</.button>
      <.button phx-click="create" id="button-recreate">Recreate</.button>
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
            <:row label="Birthrate" property="birth_rate" />
            <:row label="Deathrate" property="death_rate" />
            <:row label="Disease" property="disease_rate" />
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
    value = MyLiege.get_property(assigns.property)
    form = property_form(assigns.property, value)

    assigns =
      assign(assigns,
        value: value,
        form: form,
        id: "property-" <> String.replace(assigns.property, ".", "-"),
        edit: Enum.member?(assigns.edit_items, assigns.property)
      )

    ~H"""
    <div class="relative" id={@id}>
      <%= if @edit do %>
        <div class="absolute left-0 -bottom-6 w-32 rounded-md border border-sky-400 py-1 pr-1 bg-sky-800">
          <.form
            :let={f}
            for={@form}
            as={:realm}
            phx-submit="change_property"
            class="flex items-center"
          >
            <.icon name="la-angle-left" class="align-middle" />
            <.input field={f[:property]} value={@property} type="hidden" />
            <.input field={f[:value]} value={@value} size="5" input_class="mt-0 py-1 px-2 text-right" />
            <.button class="py-1 px-2 ml-2" id="button-change">
              <.icon name="la-upload" />
            </.button>
          </.form>
        </div>
      <% else %>
        <span><%= @value %></span>
        <a href="#" phx-click="edit_property" phx-value-property={@property}>
          <.icon name="la-edit" />
        </a>
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
