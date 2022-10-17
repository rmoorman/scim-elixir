import Config

config :logger, level: :warn

config :scim, SCIM.TestRepo,
  database: "test#{System.get_env("MIX_TEST_PARTITION")}.sqlite3",
  pool: Ecto.Adapters.SQL.Sandbox
