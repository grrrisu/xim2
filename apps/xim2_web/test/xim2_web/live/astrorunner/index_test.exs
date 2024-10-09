defmodule Xim2Web.AstrorunnerLive.IndexTest do
  use Xim2Web.ConnCase
  import Phoenix.LiveViewTest

  alias Phoenix.PubSub

  setup do
    Astrorunner.clear()
    PubSub.subscribe(Xim2.PubSub, "astrorunner")
    on_exit(fn -> PubSub.unsubscribe(Xim2.PubSub, "astrorunner") end)
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
    assert_receive(:setup_done)
    assert view |> has_element?("h3", "Arbeitsmarkt")
    assert view |> has_element?("div#deck-pilots")
  end

  test "take a card", %{conn: conn} do
    Astrorunner.setup(["me"])
    {:ok, view, _html} = live(conn, "/astrorunner")
    refute view |> has_element?("div#deck-crew > :last-child")
    assert view |> element("div#deck-pilots > :last-child") |> render_click()
    assert view |> has_element?("div#deck-crew > :last-child")
  end
end
