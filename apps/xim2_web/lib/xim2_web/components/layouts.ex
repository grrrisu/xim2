defmodule Xim2Web.Layouts do
  use Xim2Web, :html

  embed_templates "layouts/*"

  attr :flash, :map, default: %{}
  attr :title, :string, default: nil, doc: "Page Title"
  attr :back, :string, default: nil, doc: "~p\"/path/to/parent\""
  attr :back_title, :string, default: "Home"
  slot :inner_block, required: true
  slot :footer, required: false

  def app(assigns) do
    ~H"""
    <.flexbox_col class="px-4 sm:px-6 lg:px-8">
      <header>
        <h2>Xim 2</h2>
        <.main_title>{@title}</.main_title>
        <.back navigate={@back} class="mt-16">{@back_title}</.back>
      </header>
      <main>
        <.flash_group flash={@flash} />
        {render_slot(@inner_block)}
      </main>
      <div>{render_slot(@footer)}</div>
    </.flexbox_col>
    """
  end
end
