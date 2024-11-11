defmodule Xim2Web.Monitor.Components do
  @moduledoc """
  Provides UI components for monitor views
  """
  use Phoenix.Component
  import Phoenix.LiveView

  import Xim2Web.CoreComponents

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

  attr :title, :string, required: true
  attr :name, :string, required: true
  attr :hook, :string, default: "Chart"

  def chart(assigns) do
    ~H"""
    <h3><%= @title %></h3>
    <div id={"#{@name}-container"} phx-update="ignore" class="relative">
      <canvas id={"#{@name}"} phx-hook={@hook}></canvas>
    </div>
    """
  end

  @doc """
  options:
    * stacked, default false
    * begin_at_zero, default false
    * fill, default false
  """
  def prepare_summary_chart(socket, chart, opts) do
    socket
    |> push_event("init-chart-#{chart}", %{
      type: opts[:type] || "line",
      options: %{
        stacked: opts[:stacked] || false,
        beginAtZero: opts[:begin_at_zero] || false
      },
      datasets: [
        %{
          label: "one",
          borderColor: "rgb(16, 185, 129, 0.8)",
          backgroundColor: "rgb(4, 120, 87, 0.8)",
          fill: opts[:fill] || false,
          lineTension: 0,
          borderWidth: 2
        }
      ]
    })
  end

  def push_chart_data(socket, chart_id, results) do
    socket
    |> push_event("update-chart-" <> chart_id, %{
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
