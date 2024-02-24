defmodule Xim2Web.MonitorLive.IndexTest do
  use Xim2Web.ConnCase
  import Phoenix.LiveViewTest

  setup do
    :ok
  end

  test "render", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/monitor")
    assert has_element?(view, "h1", "Monitor")
  end
end
