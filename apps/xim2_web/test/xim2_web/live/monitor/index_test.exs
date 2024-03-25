defmodule Xim2Web.MonitorLive.IndexTest do
  use Xim2Web.ConnCase
  import Phoenix.LiveViewTest

  setup do
    :ok
  end

  test "start and stop queue", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/monitor")
    assert has_element?(view, "h1", "Monitor")
    assert view |> element("#start-button") |> render_click() =~ "id=\"stop-button\""
    assert has_element?(view, "div[role=\"alert\"]", "started")
    assert view |> element("#stop-button") |> render_click() =~ "id=\"start-button\""
    assert has_element?(view, "div[role=\"alert\"]", "stopped")
  end

  test "receive queue results", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/monitor")

    result = %{
      queue: :test,
      time: DateTime.utc_now(),
      duration: 15_000,
      ok: 100,
      errors: 0
    }

    send(view.pid, {:queue_summary, result})
    assert has_element?(view, "tr", "15'00")
  end
end
