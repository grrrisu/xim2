defmodule Xim2Web.MyLiegeLive.Population do
  alias Phoenix.PubSub
  use Xim2Web, :live_view

  def mount(_params, _session, socket) do
    # dbg(params)
    socket = if connected?(socket), do: prepare_realm(socket), else: assign(socket, realm: nil)

    {:ok,
     socket
     |> assign(
       edit_items: [],
       page_title: "My Liege",
       deltas: nil,
       changes: nil,
       step_totals: nil,
       step_deltas: nil
     )
     |> prepare_chart(
       "population-history-chart",
       [%{label: "population"}],
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

  def handle_info({:population_simulated, changes}, socket) do
    results =
      changes
      |> List.first()
      |> then(fn {_key, value, _delta} -> %{population: value} end)
      |> aggregate([[:population], [:working, :poverty], [:gen_1, :gen_2, :gen_3]])
      |> List.first()

    deltas =
      changes
      |> List.first()
      |> then(fn {_key, _value, delta} -> %{population: delta} end)
      |> aggregate([[:population], [:working, :poverty], [:gen_1, :gen_2, :gen_3]])
      |> List.first()

    step_totals =
      changes
      |> Enum.map(fn {key, value, _delta} ->
        {key,
         aggregate(%{population: value}, [
           [:population],
           [:working, :poverty],
           [:gen_1, :gen_2, :gen_3]
         ])}
      end)

    step_deltas =
      changes
      |> Enum.map(fn {key, _value, delta} ->
        {key,
         aggregate(%{population: delta}, [
           [:population],
           [:working, :poverty],
           [:gen_1, :gen_2, :gen_3]
         ])}
      end)

    {:noreply,
     socket
     |> assign(
       deltas: deltas,
       changes: changes,
       step_totals: step_totals,
       step_deltas: step_deltas
     )
     |> push_event("update-json-log-output", deltas)
     |> push_chart_data("population-history-chart", [results.value])}
  end

  def handle_info({_sim, _attr, _value} = _event, socket) do
    # dbg(event)
    {:noreply, socket}
  end

  def handle_info(_msg, socket) do
    # dbg(msg)
    {:noreply, socket}
  end

  def aggregate(changes, [properties | []]) do
    Enum.map(properties, &aggregate(Map.get(changes, &1), &1))
  end

  def aggregate(changes, [properties | children]) do
    Enum.map(properties, fn property ->
      children = aggregate(Map.get(changes, property), children)

      %{
        name: property,
        value: Enum.reduce(children, 0.0, fn child, sum -> sum + Map.get(child, :value) end),
        children: children
      }
    end)
  end

  def aggregate(value, property) do
    %{name: property, value: value}
  end

  def property_form(property, value) do
    %{"value" => value, "property" => property} |> to_form()
  end

  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} title="My Liege" back={~p"/my_liege"} back_title="Scenarios">
      <%= if @realm do %>
        <.flexbox_col>
          <.actions />
          <.box_grid>
            <:box>
              <.storage realm={@realm} edit_items={@edit_items} />
              <.population data={@realm.population} edit_items={@edit_items} />
            </:box>
            <:box><.statistic deltas={@deltas} /></:box>
          </.box_grid>
          <.box_grid>
            <:box>
              <.action_box class="mb-2">
                <.sim_steps_table changes={@step_totals} />
              </.action_box>
              <.action_box class="mb-2">
                <.sim_steps_table changes={@step_deltas} />
              </.action_box>
            </:box>
            <:box></:box>
            <:box>
              <.json_log_output />
            </:box>
          </.box_grid>
        </.flexbox_col>
      <% else %>
        <p>Loading...</p>
      <% end %>
    </Layouts.app>
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
          <.social_stratum social={@data.working} name="working" />
          <.social_stratum social={@data.poverty} name="poverty" />
        </div>
        <div>
          <.property_table realm={@data} edit_items={@edit_items}>
            <:row label="Birthrate" property="population.birth_rate" />
            <:row label="Deathrate" property="population.death_rate" />
            <:row label="Disease" property="population.disease_rate" />
          </.property_table>
        </div>
      </div>
    </.action_box>
    """
  end

  def sim_steps_table(%{changes: nil} = assigns) do
    ~H"""
    Wait for first simulation
    """
  end

  def sim_steps_table(%{changes: changes} = assigns) do
    assigns =
      assign(assigns,
        sim_steps: ["structure" | Enum.map(changes, fn {step, _} -> step end)],
        changes: Enum.map(changes, fn {_, [change]} -> change end)
      )

    ~H"""
    <table class="w-full">
      <thead>
        <th :for={sim_step <- @sim_steps}>{sim_step}</th>
      </thead>
      <tbody class="border-t border-sky-400">
        <.sim_steps_row changes={@changes} path={[]} />
      </tbody>
    </table>
    """
  end

  def sim_steps_row(%{path: path, changes: changes} = assigns) do
    assigns =
      assign(assigns,
        name: changes |> List.first() |> get_in(path ++ [:name]),
        children: changes |> List.first() |> get_in(path ++ [:children]) || [],
        indention: "ml-#{Enum.count(path)}"
      )

    ~H"""
    <tr class="border-b border-sky-700">
      <td><span class={@indention}>{@name}</span></td>
      <td :for={change <- @changes} class="text-right">
        {get_in(change, @path ++ [:value]) |> Float.round(2)}
      </td>
    </tr>
    <.sim_steps_row
      :for={{_, i} <- Enum.with_index(@children)}
      changes={@changes}
      path={@path ++ [:children, Access.at(i)]}
    />
    """
  end

  def statistic(assigns) do
    {:ok, output} = Jason.encode(assigns.deltas)
    assigns = assign(assigns, log_output: output)

    ~H"""
    <.action_box class="mb-2">
      <.small_title>
        <.icon name="la-chart-line" class="la-2x align-bottom mr-1" />Statistics
      </.small_title>
      <.chart title="Population" name="population-history-chart" />
    </.action_box>
    """
  end

  def json_log_output(assigns) do
    ~H"""
    <.action_box class="mb-2">
      <small_title>Delta Output</small_title>
      <.json_ouput id="log-output" />
    </.action_box>
    """
  end

  def property_table(assigns) do
    ~H"""
    <table class="">
      <tbody>
        <tr :for={row <- @row}>
          <td><strong>{row.label}</strong></td>
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
        <div class="absolute z-10 left-2 -bottom-10 w-32 rounded-md border border-sky-400 py-1 pr-1 bg-sky-800">
          <.form
            :let={f}
            for={@form}
            as={:realm}
            phx-submit="change_property"
            class="flex items-center"
          >
            <.icon name="la-angle-left" class="align-middle" />
            <input name={f[:property].name} value={@property} type="hidden" />
            <.input field={f[:value]} value={@value} size="5" />
            <.button class="py-1 px-2 ml-2" id="button-change">
              <.icon name="la-upload" />
            </.button>
          </.form>
        </div>
      <% else %>
        <span>{@value}</span>
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
        <.icon name="la-users" class="la-2x align-middle mr-1" />{@title}
      </strong>
      <p>
        <span class="gen_1">{@social.gen_1 |> Float.round(2)}</span>
        | <span class="gen_2">{@social.gen_2 |> Float.round(2)}</span>
        | <span class="gen_3">{@social.gen_3 |> Float.round(2)}</span>
      </p>
    </div>
    """
  end
end
