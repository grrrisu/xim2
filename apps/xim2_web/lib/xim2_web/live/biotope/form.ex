defmodule Xim2Web.BiotopeLive.Form do
  use Xim2Web, :live_component

  alias Ecto.Changeset

  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign(form: form_data(%{"width" => nil, "height" => nil}) |> to_form(as: :grid))}
  end

  def handle_event("validate", %{"grid" => params}, socket) do
    {:noreply,
     assign(socket, form: form_data(params) |> Map.put(:action, :insert) |> to_form(as: :grid))}
  end

  def handle_event("create", %{"grid" => params}, socket) do
    case form_data(params) |> Changeset.apply_action(:update) do
      {:ok, data} ->
        send(self(), {:form_submitted, data})
        {:noreply, socket}

      {:error, changeset} ->
        {:noreply, assign(socket, form: to_form(changeset, as: :grid))}
    end
  end

  def render(assigns) do
    ~H"""
    <div>
      <h3>Create new Biotope</h3>
      <.form
        :let={f}
        id="biotope-form"
        for={@form}
        phx-change="validate"
        phx-submit="create"
        phx-target={@myself}
      >
        <div class="flex items-start mt-4 space-x-8 ">
          <.input field={@form[:width]} label="Width" errors={f.errors} />
          <.input field={@form[:height]} label="Height" errors={f.errors} />
          <div class="mt-8 flex items-end gap-6">
            <.button>Create</.button>
            <.button patch={~p"/"} class="btn-secondary btn-outline">Cancel</.button>
          </div>
        </div>
      </.form>
    </div>
    """
  end

  defp form_data(params) do
    types = %{height: :integer, width: :integer}

    {%{}, types}
    |> Changeset.cast(params, Map.keys(types))
    |> Changeset.validate_required([:width, :height])
    |> Changeset.validate_number(:width, greater_than: 0, less_than_or_equal_to: 100)
    |> Changeset.validate_number(:height, greater_than: 0, less_than_or_equal_to: 50)
  end
end
