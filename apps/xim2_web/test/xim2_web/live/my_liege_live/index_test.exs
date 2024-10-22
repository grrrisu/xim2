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
end
