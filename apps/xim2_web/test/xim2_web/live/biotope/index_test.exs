defmodule Xim2Web.BiotopeLive.IndexTest do
  use Xim2Web.ConnCase
  import Phoenix.LiveViewTest

  setup do
    Biotope.clear()
  end

  test "render a grid", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/biotope")
    assert has_element?(view, "h1", "Biotope")
    # =~ "Grid created"
    assert view |> element("form") |> render_submit(%{grid: %{width: 10, height: 5}})
    assert has_element?(view, "#grid.grid")
  end
end
