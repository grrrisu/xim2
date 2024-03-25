defmodule Xim2Web.BiotopeLive.IndexTest do
  use Xim2Web.ConnCase
  import Phoenix.LiveViewTest

  setup do
    Biotope.clear()
    :ok
  end

  test "render a grid", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/biotope")
    assert has_element?(view, "h1", "Biotope")
    # =~ "Grid created"
    assert view |> element("form") |> render_submit(%{grid: %{width: 10, height: 5}})
    assert has_element?(view, "#vegetation.grid")
  end

  test "reset grid", %{conn: conn} do
    Biotope.create(2, 2)
    {:ok, view, _html} = live(conn, "/biotope")
    assert has_element?(view, "#vegetation.grid")
    assert view |> element("#reset-button") |> render_click()
    assert has_element?(view, "#biotope-form")
  end

  test "update grid", %{conn: conn} do
    Biotope.create(2, 2)
    {:ok, view, _html} = live(conn, "/biotope")

    send(
      view.pid,
      {:simulation_biotope, :simulation_aggregated,
       %{
         vegetation: [%{position: {0, 0}, size: 800}],
         herbivore: [%{position: {0, 1}, size: 200}],
         predator: []
       }}
    )

    assert view |> has_element?("#vegetation-0-0", ~r/800/)
    assert view |> has_element?("#herbivore-0-1", ~r/200/)
  end
end
