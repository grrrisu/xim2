defmodule Xim2Web.GridLive.ShowTest do
  use Xim2Web.ConnCase
  import Phoenix.LiveViewTest

  test "render a grid", %{conn: conn} do
    {:ok, view, html} = live(conn, "/grid")
    assert html =~ "<h1>Grid</h1>"
    assert has_element?(view, "#grid.grid")
  end
end
