defmodule Monsum.BoardgameComponents do
  @moduledoc """
  components for board games
  """
  use Phoenix.Component

  alias Phoenix.LiveView.JS

  attr :id, :string, required: false, default: nil
  attr :class, :string, required: false, default: ""
  attr :border_class, :string, required: false, default: ""
  attr :height, :integer, default: 448
  attr :click, :string, required: false, default: nil
  attr :card_value, :any, required: false, default: nil
  attr :mounted, :any, required: false, default: nil
  attr :remove, :any, required: false, default: nil
  slot :title, required: false
  slot :picture, required: false
  slot :body_title, required: false
  slot :body

  @card_ratio 64 / 89

  def card(assigns) do
    assigns = assign(assigns, width: (assigns.height * @card_ratio) |> Float.round(3))

    ~H"""
    <div
      id={@id}
      class={[
        "relative bg-gray-50 text-gray-800 rounded-lg drop-shadow-md border border-gray-800 p-4",
        @border_class
      ]}
      style={"height: #{@height}px; width: #{@width}px"}
      phx-click={@click}
      phx-value-card={@card_value}
      phx-mounted={@mounted}
      phx-remove={@remove}
    >
      <div class={["border border-gray-800 h-full", @class]}>
        <div class="flex flex-col h-full">
          <div class="text-center font-bold py-px border-b border-gray-800">
            {render_slot(@title)}
          </div>
          <div class="grow flex flex-col justify-stretch">
            <div class="h-1/2 overflow-hidden">
              {render_slot(@picture)}
            </div>
            <div class="h-1/2 flex flex-col">
              <div class="text-center font-bold border-y border-gray-800">
                {render_slot(@body_title)}
              </div>
              <div class="grow p-2">
                {render_slot(@body)}
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end

  ## transitions

  def card_slide_in(js \\ %JS{}) do
    js
    |> JS.transition({"ease-out duration-1000", "-left-32", "left-0"},
      time: 1000
    )
  end

  def card_fade_out(js \\ %JS{}) do
    js
    |> JS.transition({"ease-in duration-300", "top-0 opacity-100", "top-24 opacity-0"},
      time: 300
    )
  end
end
