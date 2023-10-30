defmodule Xim2Web.GridLive.ShowTest do
  use Xim2Web.ConnCase
  import Phoenix.LiveViewTest

  test "render a grid", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/grid")
    assert has_element?(view, "h1", "Grid")
    assert has_element?(view, "#grid.grid")
  end
end
