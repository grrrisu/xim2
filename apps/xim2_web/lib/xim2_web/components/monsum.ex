defmodule Monsum do
  @moduledoc """
  uses tailwindcss, expects the following global classes:
  see assets/css/app.css
  """
  use Phoenix.Component

  import Xim2Web.CoreComponents

  def main_title(assigns) do
    ~H"""
    <h1 class="text-slate-200 text-4xl font-light mb-6"><%= render_slot(@inner_block) %></h1>
    """
  end

  attr :small, :string, required: true, doc: "smaller 768px"
  attr :medium, :string, default: nil, doc: "min 768px"
  attr :large, :string, default: nil, doc: "min 1024px"
  attr :class, :string, default: "w-full"

  def picture(assigns) do
    ~H"""
    <picture>
      <%= if @medium do %>
        <source srcset={@medium} media="(min-width: 768px)" />
      <% end %>
      <%= if @large do %>
        <source srcset={@large} media="(min-width: 1024px)" />
      <% end %>
      <img src={@small} class={@class} />
    </picture>
    """
  end

  attr :link, :string, required: true
  attr :class, :string, doc: "class "
  slot :icon
  slot :title
  slot :inner_block, required: true

  def hero_card(assigns) do
    ~H"""
    <.link navigate={@link} class={@class}>
      <div class="flex flex-col opacity-100 items-center p-6 space-y-3 text-center bg-sky-800 hover:bg-sky-700 rounded-xl border border-sky-600">
        <span class="inline-block p-3 text-white bg-sky-600 rounded-full">
          <%= render_slot(@icon) %>
        </span>
        <h2 class="text-xl font-semibold text-sky-300 capitalize">
          <%= render_slot(@title) %>
        </h2>
        <p class="text-sky-100">
          <%= render_slot(@inner_block) %>
        </p>
      </div>
    </.link>
    """
  end

  attr :running, :boolean, required: true

  def start_button(%{running: false} = assigns) do
    ~H"""
    <.button phx-click="start" phx-disable-with="Starting..."><.icon name="hero-play" />Start</.button>
    """
  end

  def start_button(%{running: true} = assigns) do
    ~H"""
    <.button phx-click="stop" phx-disable-with="Stopping..."><.icon name="hero-pause" />Stop</.button>
    """
  end

  # --- core components modified colors ---

  @doc """
  Renders a back navigation link.

  ## Examples

      <.back navigate={~p"/posts"}>Back to posts</.back>
  """
  attr :navigate, :any, required: true
  slot :inner_block, required: true

  def back(assigns) do
    ~H"""
    <div class="mt-16">
      <.link navigate={@navigate} class="text-sm font-semibold leading-6">
        <.icon name="hero-arrow-left-solid" class="h-3 w-3" />
        <%= render_slot(@inner_block) %>
      </.link>
    </div>
    """
  end

  @doc """
  Renders a button.

  ## Examples

      <.button>Send!</.button>
      <.button phx-click="go" class="ml-2">Send!</.button>
  """
  attr :type, :string, default: nil
  attr :class, :string, default: nil
  attr :rest, :global, include: ~w(disabled form name value)

  slot :inner_block, required: true

  def button(assigns) do
    ~H"""
    <button
      type={@type}
      class={[
        "phx-submit-loading:opacity-75 rounded-lg bg-orange-500 hover:bg-orange-400 py-2 px-3",
        "font-semibold leading-6 text-slate-900 active:text-white/80 ",
        "focus:ring-1 focus:ring-offset-1 focus:outline-none focus:ring-offset-orange-200",
        @class
      ]}
      {@rest}
    >
      <%= render_slot(@inner_block) %>
    </button>
    """
  end

  @doc """
  Renders an input with label and error messages.

  A `Phoenix.HTML.FormField` may be passed as argument,
  which is used to retrieve the input name, id, and values.
  Otherwise all attributes may be passed explicitly.

  ## Types

  This function accepts all HTML input types, considering that:

    * You may also set `type="select"` to render a `<select>` tag

    * `type="checkbox"` is used exclusively to render boolean values

    * For live file uploads, see `Phoenix.Component.live_file_input/1`

  See https://developer.mozilla.org/en-US/docs/Web/HTML/Element/input
  for more information.

  ## Examples

      <.input field={@form[:email]} type="email" />
      <.input name="my-input" errors={["oh no!"]} />
  """
  attr :id, :any, default: nil
  attr :name, :any
  attr :label, :string, default: nil
  attr :value, :any

  attr :type, :string,
    default: "text",
    values: ~w(checkbox color date datetime-local email file hidden month number password
               range radio search select tel text textarea time url week)

  attr :field, Phoenix.HTML.FormField,
    doc: "a form field struct retrieved from the form, for example: @form[:email]"

  attr :errors, :list, default: []
  attr :checked, :boolean, doc: "the checked flag for checkbox inputs"
  attr :prompt, :string, default: nil, doc: "the prompt for select inputs"
  attr :options, :list, doc: "the options to pass to Phoenix.HTML.Form.options_for_select/2"
  attr :multiple, :boolean, default: false, doc: "the multiple flag for select inputs"

  attr :rest, :global,
    include: ~w(accept autocomplete capture cols disabled form list max maxlength min minlength
                multiple pattern placeholder readonly required rows size step)

  slot :inner_block

  def input(%{field: %Phoenix.HTML.FormField{} = field} = assigns) do
    assigns
    |> assign(field: nil, id: assigns.id || field.id)
    |> assign(:errors, Enum.map(field.errors, &translate_error(&1)))
    |> assign_new(:name, fn -> if assigns.multiple, do: field.name <> "[]", else: field.name end)
    |> assign_new(:value, fn -> field.value end)
    |> input()
  end

  def input(%{type: "checkbox"} = assigns) do
    assigns =
      assign_new(assigns, :checked, fn ->
        Phoenix.HTML.Form.normalize_value("checkbox", assigns[:value])
      end)

    ~H"""
    <div phx-feedback-for={@name}>
      <label class="flex items-center gap-4 text-sm leading-6 text-zinc-600">
        <input type="hidden" name={@name} value="false" />
        <input
          type="checkbox"
          id={@id}
          name={@name}
          value="true"
          checked={@checked}
          class="rounded border-zinc-300 text-zinc-900 focus:ring-0"
          {@rest}
        />
        <%= @label %>
      </label>
      <.error :for={msg <- @errors}><%= msg %></.error>
    </div>
    """
  end

  def input(%{type: "select"} = assigns) do
    ~H"""
    <div phx-feedback-for={@name}>
      <.label for={@id}><%= @label %></.label>
      <select
        id={@id}
        name={@name}
        class="mt-2 block w-full rounded-md border border-gray-300 bg-white shadow-sm focus:border-zinc-400 focus:ring-0 sm:text-sm"
        multiple={@multiple}
        {@rest}
      >
        <option :if={@prompt} value=""><%= @prompt %></option>
        <%= Phoenix.HTML.Form.options_for_select(@options, @value) %>
      </select>
      <.error :for={msg <- @errors}><%= msg %></.error>
    </div>
    """
  end

  def input(%{type: "textarea"} = assigns) do
    ~H"""
    <div phx-feedback-for={@name}>
      <.label for={@id}><%= @label %></.label>
      <textarea
        id={@id}
        name={@name}
        class={[
          "mt-2 block w-full rounded-lg text-zinc-900 focus:ring-0 sm:text-sm sm:leading-6",
          "min-h-[6rem] phx-no-feedback:border-zinc-300 phx-no-feedback:focus:border-zinc-400",
          @errors == [] && "border-zinc-300 focus:border-zinc-400",
          @errors != [] && "border-rose-400 focus:border-rose-400"
        ]}
        {@rest}
      ><%= Phoenix.HTML.Form.normalize_value("textarea", @value) %></textarea>
      <.error :for={msg <- @errors}><%= msg %></.error>
    </div>
    """
  end

  # All other inputs text, datetime-local, url, password, etc. are handled here...
  def input(assigns) do
    ~H"""
    <div phx-feedback-for={@name}>
      <.label for={@id}><%= @label %></.label>
      <input
        type={@type}
        name={@name}
        id={@id}
        value={Phoenix.HTML.Form.normalize_value(@type, @value)}
        class={[
          "mt-2 block w-full rounded-lg bg-slate-800 text-sky-100 focus:ring-0 sm:text-sm sm:leading-6",
          "phx-no-feedback:border-slate-500 phx-no-feedback:focus:border-sky-600 phx-no-feedback:focus:bg-sky-950",
          @errors == [] && "border-slate-500 focus:border-sky-600 focus:bg-sky-950",
          @errors != [] && "border-orange-400 focus:border-orange-300"
        ]}
        {@rest}
      />
      <.error :for={msg <- @errors}><%= msg %></.error>
    </div>
    """
  end

  @doc """
  Renders a label.
  """
  attr :for, :string, default: nil
  slot :inner_block, required: true

  def label(assigns) do
    ~H"""
    <label for={@for} class="block font-semibold leading-6 text-sky-100">
      <%= render_slot(@inner_block) %>
    </label>
    """
  end

  @doc """
  Generates a generic error message.
  """
  slot :inner_block, required: true

  def error(assigns) do
    ~H"""
    <p class="mt-3 flex gap-3 text-sm leading-6 text-orange-400 phx-no-feedback:hidden">
      <.icon name="hero-exclamation-circle-mini" class="mt-0.5 h-5 w-5 flex-none" />
      <%= render_slot(@inner_block) %>
    </p>
    """
  end
end
