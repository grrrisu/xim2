defmodule Xim2Web.AstrorunnerLive.IndexTest do
  use Xim2Web.ConnCase
  import Phoenix.LiveViewTest

  setup do
    Astrorunner.clear()
    :ok
  end

  test "before setup", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/astrorunner")
    assert has_element?(view, "h1", "Astrorunner")
  end

  test "setup game", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/astrorunner")
    assert view |> has_element?("p", "No game available")
    assert view |> element("button", "Setup Board") |> render_click()
    Process.sleep(100)
    assert view |> has_element?("h3", "Arbeitsmarkt")
    assert view |> has_element?("div#deck-pilots")
  end

  test "take a card", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/astrorunner")
    assert view |> element("button", "Setup Board") |> render_click()
    Process.sleep(100)
    assert view |> element("div#card-pilots-0") |> render_click(%{"card" => "pilots-0"})
    Process.sleep(100)
    open_browser(view)
    refute view |> has_element?("div#card-pilots-0")
  end
end
