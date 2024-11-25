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
      <.main_box>
        <:header>
          <.title>Scenarios</.title>
        </:header>
        <.hero_card link={~p"/my_liege/population"} class="mb-6 mx-3 basis-1/5">
          <:icon><.icon name="la-users" class="la-2x" /></:icon>
          <:title>Population</:title>
          Sim birth and death, diseases and feeding poeple
        </.hero_card>
        <.hero_card link={~p"/my_liege/factory"} class="mb-6 mx-3 basis-1/5">
          <:icon><.icon name="la-industry" class="la-2x" /></:icon>
          <:title>Factories</:title>
          Farms, wood, tools, black smiths
        </.hero_card>
      </.main_box>
    </.main_section>
    """
  end
end
