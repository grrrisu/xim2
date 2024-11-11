defmodule Xim2Web.Monitor.Components do
  @moduledoc """
  Provides UI components for monitor views
  """
  use Phoenix.Component

  def duration_table(assigns) do
    ~H"""
    <table class="table-auto w-full">
      <thead class="text-sky-400">
        <th>Time</th>
        <th>Duration (µm)</th>
        <th :if={@items}>Overhead Queue (µm)</th>
      </thead>
      <tbody
        id="durations"
        phx-update="stream"
        class="divide-y divide-sky-800 border-t border-sky-600 text-sm leading-6 text-sky-300"
      >
        <tr :for={{dom_id, item} <- @durations} id={dom_id}>
          <td class="text-right"><%= Calendar.strftime(item.time, "%H:%M:%S:%f") %></td>
          <td class="text-right"><%= item.duration |> number_format() %></td>
          <td :if={@items} class="text-right">
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
          <td class="text-center"><%= item.entity %></td>
          <td class="text-left"><%= item.message %></td>
        </tr>
      </tbody>
    </table>
    """
  end
end
