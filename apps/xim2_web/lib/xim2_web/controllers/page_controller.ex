defmodule Xim2Web.PageController do
  use Xim2Web, :controller

  def home(conn, _params) do
    # The home page is often custom made,
    # so skip the default app layout.
    render(conn, :home)
  end

  def colors(conn, _params) do
    conn
    |> assign(:page_title, "Colors")
    |> render(:colors)
  end
end
