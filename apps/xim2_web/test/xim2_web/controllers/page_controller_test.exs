defmodule Xim2Web.PageControllerTest do
  use Xim2Web.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, ~p"/")
    assert html_response(conn, 200) =~ "Xim 2"
  end
end
