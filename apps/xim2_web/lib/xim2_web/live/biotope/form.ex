defmodule Xim2Web.BiotopeLive.Form do
  use Xim2Web, :live_component

  alias Ecto.Changeset

  def update(assigns, socket) do
    {:ok, socket
      |> assign(assigns)
      |> assign(form: form_data(%{"width" => nil, "height" => nil}) |> to_form(as: :grid))
    }
  end

  def handle_event("validate", %{"grid" => params}, socket) do
    {:noreply, assign(socket, form: form_data(params) |> Map.put(:action, :insert) |> to_form(as: :grid) )}
  end

  def handle_event("create", %{"grid" => params}, socket) do
    form = case form_data(params) |> Changeset.apply_action(:update) do
      {:ok, data} -> to_form(data, as: :grid) # send(self(), {:form_submitted, data})
      {:error, changeset} -> to_form(changeset, as: :grid) # {:noreply, assign(socket, form: form}}
    end
    {:noreply, assign(socket, form: form)}
  end

  def render(assigns) do
    ~H"""
    <div>
      <h3>Create new Biotope</h3>
      <.form :let={f} for={@form} as="grid" phx-change="validate" phx-submit="create" phx-target={@myself}>
        <div class="mt-10 space-y-8">
          <.input field={@form[:width]} label="Width" errors={f.errors}/>
          <.input field={@form[:height]} label="Height" errors={f.errors}/>
          <div class="mt-2 flex items-center justify-between gap-6">
            <.button>Save</.button>
            <.link patch={~p"/biotope"}>Cancel</.link>
          </div>
        </div>
      </.form>
    </div>
    """
  end

  defp form_data(params) do
    types = %{height: :integer, width: :integer}
    form = {%{}, types}
    |> Changeset.cast(params, Map.keys(types))
    |> Changeset.validate_required([:width, :height])
  end
end
