defmodule Xim2Web.MyLiegeLive.Factory do
  alias Phoenix.PubSub
  use Xim2Web, :live_view

  import Xim2Web.ProjectComponents

  def mount(_params, _session, socket) do
    socket = if connected?(socket), do: prepare_realm(socket), else: assign(socket, realm: nil)

    {:ok, socket |> assign(page_title: "My Liege - Factory")}
  end

  def prepare_realm(socket) do
    PubSub.subscribe(Xim2Web.PubSub, "my_liege")
    handle_change(MyLiege.create(:factory), socket)
  end

  def handle_change(realm, socket) do
    assign(socket, realm: realm)
  end

  def render(assigns) do
    ~H"""
    <.main_section title="My Liege - Factory" back={~p"/my_liege"} back_title="Scenarios">
    </.main_section>
    """
  end
end
