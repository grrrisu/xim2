defmodule Monsum.Chart do
  @moduledoc """
  components for using chart.js
  see monitor.js for corresponding chart hooks
  """
  use Phoenix.Component

  import Phoenix.LiveView

  attr :title, :string, required: true
  attr :name, :string, required: true
  attr :hook, :string, default: "Chart"

  def chart(assigns) do
    ~H"""
    <h3>{@title}</h3>
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
  @dataset_opts %{
    borderColor: "rgb(16, 185, 129, 0.8)",
    backgroundColor: "rgb(4, 120, 87, 0.8)",
    fill: false,
    lineTension: 0,
    borderWidth: 2
  }
  def prepare_chart(socket, chart_id, datasets \\ [%{label: "one"}], opts) do
    socket
    |> push_event("init-chart-#{chart_id}", %{
      type: opts[:type] || "line",
      options: %{
        stacked: opts[:stacked] || false,
        beginAtZero: opts[:begin_at_zero] || false
      },
      datasets: Enum.map(datasets, &Map.merge(@dataset_opts, &1))
    })
  end

  def push_chart_data(socket, chart_id, results) do
    socket
    |> push_event("update-chart-" <> chart_id, %{
      x_axis: DateTime.now!("Etc/UTC") |> DateTime.to_iso8601(),
      results: results
    })
  end
end
