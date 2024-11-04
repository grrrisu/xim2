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
    assert view |> element("#property-storage-food") |> render() =~ "94"
    assert view |> element("#property-storage-food a") |> render_click() =~ "94"

    view
    |> element("#property-storage-food form")
    |> render_submit(%{realm: %{property: "storage.food", value: "100"}})

    assert view |> element("#property-storage-food") |> render() =~ "100"
  end

  test "sim step", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/my_liege")
    assert view |> element("#social_stratum_poverty .gen_1") |> render() =~ "10"
    view |> element("#button-sim-step") |> render_click()
    refute view |> element("#social_stratum_poverty .gen_1") |> render() =~ "10"
  end

  test "recreate", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/my_liege")
    assert view |> element("#social_stratum_poverty .gen_1") |> render() =~ "10"
    view |> element("#button-sim-step") |> render_click()
    refute view |> element("#social_stratum_poverty .gen_1") |> render() =~ "10"
    view |> element("#button-recreate") |> render_click()
    assert view |> element("#social_stratum_poverty .gen_1") |> render() =~ "10"
  end
end
