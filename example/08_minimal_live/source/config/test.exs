config(:live_view_studio, LiveViewStudio.Repo,
  username: "postgres",
  password: "postgres",
  database: "live_view_studio_test#{System.get_env("MIX_TEST_PARTITION")}",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox
)

config(:live_view_studio, LiveViewStudioWeb.Endpoint, http: [port: 4002], server: false)
config(:logger, level: :warn)
