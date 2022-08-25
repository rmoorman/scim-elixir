import Config

config :avatarish, :scim_auth_header, "Bearer vriq6pvXVY"

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :avatarish, Avatarish.Repo,
  database: "avatarish_test#{System.get_env("MIX_TEST_PARTITION")}.sqlite3",
  pool: Ecto.Adapters.SQL.Sandbox

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :avatarish, AvatarishWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "BeDwwgX9ITXv+683gEi9T1xPMGoAw+gMnNL12jDNTOz9JeJyxMddSAI/zCVCN8BD",
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
