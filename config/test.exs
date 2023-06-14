import Config

config :factoid,
  ecto_repos: [Factoid.Repo],
  generators: [binary_id: true]

config :factoid, Factoid.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "factoid_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 10,
  migration_primary_key: [type: :binary_id],
  migration_timestamps: [type: :utc_datetime_usec, inserted_at: :created_at]

config :logger, level: :warning
