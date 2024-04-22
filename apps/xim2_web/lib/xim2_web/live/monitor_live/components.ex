defmodule Xim2Web.Monitor.Components do
  @moduledoc """
  Provides UI components for monitor views
  """
  use Phoenix.Component
  import Phoenix.LiveView

  import Monsum
  import Xim2Web.CoreComponents

  attr :title, :string
  attr :back, :string
  slot :inner_block, required: true
  slot :footer

  def main_section(assigns) do
    ~H"""
    <section class="flex flex-col">
      <div>
        <.main_title><%= @title %></.main_title>
        <.back navigate={@back}>Home</.back>
      </div>
      <div>
        <%= render_slot(@inner_block) %>
      </div>
      <div><%= render_slot(@footer) %></div>
    </section>
    """
  end

  def boxes(assigns) do
    ~H"""
    <div class="flex flex-row flex-wrap p-2">
      <div :for={box <- @box} class={["flex-auto", @width]}>
        <%= render_slot(box) %>
      </div>
    </div>
    """
  end

  def info_card(assigns) do
    ~H"""
    <div>
      <span class="align-super"><%= @value %></span>
      <.icon name={@icon} class="la-2x" />
    </div>
    """
  end

  def chart(assigns) do
    ~H"""
    <h3><%= @title %></h3>
    <div id={"#{@name}-container"} phx-update="ignore" class="relative">
      <canvas id={"#{@name}"} phx-hook={@hook}></canvas>
    </div>
    """
  end

  def push_chart_data(socket, event, results) do
    socket
    |> push_event(event, %{
      x_axis: DateTime.now!("Etc/UTC") |> DateTime.to_iso8601(),
      results: results
    })
  end

  def duration_table(assigns) do
    ~H"""
    <table class="table-auto w-full">
      <thead class="text-sky-400">
        <th>Time</th>
        <th>Duration (µm)</th>
        <th>Overhead Queue (µm)</th>
      </thead>
      <tbody
        id="durations"
        phx-update="stream"
        class="divide-y divide-sky-800 border-t border-sky-600 text-sm leading-6 text-sky-300"
      >
        <tr :for={{dom_id, item} <- @durations} id={dom_id}>
          <td class="text-right"><%= Calendar.strftime(item.time, "%H:%M:%S:%f") %></td>
          <td class="text-right"><%= item.duration |> number_format() %></td>
          <td class="text-right">
            <%= (item.duration - @items * @timeout / @tasks) |> number_format() %>
          </td>
        </tr>
      </tbody>
    </table>
    """
  end

  def number_format(number, precision \\ 0) do
    Number.Delimit.number_to_delimited(number, precision: precision)
  end

  def error_message_table(assigns) do
    ~H"""
    <table class="table-auto w-full">
      <thead class="text-sky-400">
        <th>Time</th>
        <th>Entity</th>
        <th>Message</th>
      </thead>
      <tbody
        id="error_messages"
        phx-update="stream"
        class="divide-y divide-sky-800 border-t border-sky-600 text-sm leading-6 text-sky-300"
      >
        <tr :for={{dom_id, item} <- @error_messages} id={dom_id}>
          <td class="text-right"><%= Calendar.strftime(item.time, "%H:%M:%S:%f") %></td>
          <td class="text-right"><%= item.entity %></td>
          <td class="text-right"><%= item.message %></td>
        </tr>
      </tbody>
    </table>
    """
  end
end
