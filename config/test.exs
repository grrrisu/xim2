import Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.

db_config = [
  hostname: System.get_env("POSTGRES_HOST", "localhost"),
  database: "xim2_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 10
]

db_config =
  case System.get_env("POSTGRES_USER") do
    nil ->
      db_config

    _ ->
      Keyword.merge(db_config,
        username: System.get_env("POSTGRES_USER"),
        password: System.get_env("POSTGRES_PASSWORD")
      )
  end

config :xim2, Xim2.Repo, db_config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :xim2_web, Xim2Web.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "evEoI7gD8QJzv2w3Pf3kZxTd4T+8U+tlcO2NZPDF6iJc8FQbSyA94oYlGCRN80hw",
  server: false

# Print only warnings and errors during test
config :logger, level: :warning

# In test we don't send emails.
config :xim2, Xim2.Mailer, adapter: Swoosh.Adapters.Test

# Disable swoosh api client as it is only required for production adapters.
config :swoosh, :api_client, false

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
