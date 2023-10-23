defmodule Xim2.Repo do
  use Ecto.Repo,
    otp_app: :xim2,
    adapter: Ecto.Adapters.Postgres
end
