defmodule Xim2Web.MyLiegeLive.Index do
  alias Phoenix.PubSub
  use Xim2Web, :live_view

  import Xim2Web.ProjectComponents

  def mount(_params, _session, socket) do
    socket =
      if connected?(socket) do
        PubSub.subscribe(Xim2.PubSub, "my_liege")
        MyLiege.create()
        socket = assign(socket, realm: MyLiege.get_realm())
      else
        socket = assign(socket, realm: nil)
      end

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <.main_section title="My Liege" back={~p"/"}>
      <%= if @realm do %>
        <.social_stratum social={@realm.working} name="Working" />
        <.social_stratum social={@realm.poverty} name="Poverty" />
      <% else %>
        <p>Loading...</p>
      <% end %>
    </.main_section>
    """
  end

  def social_stratum(assigns) do
    ~H"""
    <.action_box class="mb-2">
      <strong><.icon name="la-users" class="la-2x align-middle mr-1" /><%= @name %></strong>
      <p>
        <%= @social.gen_1 %> | <%= @social.gen_2 %> | <%= @social.gen_3 %>
      </p>
    </.action_box>
    """
  end
end
