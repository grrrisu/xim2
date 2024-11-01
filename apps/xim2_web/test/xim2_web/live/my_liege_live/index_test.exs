defmodule Xim2Web.MyLiegeLive.IndexTest do
  use Xim2Web.ConnCase
  import Phoenix.LiveViewTest

  alias Phoenix.PubSub

  setup do
    PubSub.subscribe(Xim2.PubSub, "my_liege")
    on_exit(fn -> PubSub.unsubscribe(Xim2.PubSub, "my_liege") end)
    :ok
  end

  test "index", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/my_liege")
    assert has_element?(view, "h1", "My Liege")
  end

  test "change food", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/my_liege")
    assert view |> element("input#realm_food") |> render() =~ "107"
    view |> element("form") |> render_submit(%{realm: %{food: "200"}})
    assert view |> element("input#realm_food") |> render() =~ "200"
  end

  test "sim step", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/my_liege")
    assert view |> element("#social_stratum_working .gen_1") |> render() =~ "10"
    view |> element("#button-sim-step") |> render_click()
    refute view |> element("#social_stratum_working .gen_1") |> render() =~ "10"
  end

  test "recreate", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/my_liege")
    assert view |> element("#social_stratum_working .gen_1") |> render() =~ "10"
    view |> element("#button-sim-step") |> render_click()
    refute view |> element("#social_stratum_working .gen_1") |> render() =~ "10"
    view |> element("#button-recreate") |> render_click()
    assert view |> element("#social_stratum_working .gen_1") |> render() =~ "10"
  end
end
