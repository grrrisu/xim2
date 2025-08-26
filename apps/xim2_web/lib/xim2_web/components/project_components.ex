defmodule Xim2Web.ProjectComponents do
  @moduledoc """
  Xim2 specific components.
  """
  use Phoenix.Component

  attr :class, :string, default: ""
  slot :header, required: false
  slot :inner_block, required: true

  def main_box(assigns) do
    ~H"""
    <div class={[
      "p-6 rounded-t-lg drop-shadow-2xl bg-sky-950 border-2 border-sky-500",
      @class
    ]}>
      <div>
        {render_slot(@header)}
      </div>
      <div class="flex flex-wrap place-content-evenly items-stretch">
        {render_slot(@inner_block)}
      </div>
    </div>
    """
  end
end
