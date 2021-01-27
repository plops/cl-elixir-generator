config(:q, Q.Repo,
  username: "postgres",
  password: "postgres",
  database: "q_test#{System.get_env("MIX_TEST_PARTITION")}",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox
)

config(:q, QWeb.Endpoint, http: [port: 4002], server: false)
config(:logger, level: :warn)
