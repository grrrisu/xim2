defmodule Xim2Web.MyLiegeLive.Index do
  alias Phoenix.PubSub
  use Xim2Web, :live_view

  import Xim2Web.ProjectComponents

  def mount(_params, _session, socket) do
    if connected?(socket), do: PubSub.subscribe(Xim2Web.PubSub, "my_liege")
    socket = assign(socket, page_title: "My Liege")
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <.main_section title="My Liege" back={~p"/"}>
      <.title>Scenarios</.title>
      <div class="flex flex-wrap place-content-evenly items-stretch">
        <.hero_card link={~p"/my_liege/scenario"} class="mb-6 mx-3 basis-1/5">
          <:icon><.icon name="la-users" class="la-2x" /></:icon>
          <:title>Population</:title>
          Sim birth and death, diseases and feeding poeple
        </.hero_card>
      </div>
    </.main_section>
    """
  end
end
