use Mix.Config
config(:q, ecto_repos: [Q.Repo])

config(:q, QWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "Wy+j/oXYSmC2gLpNSuAz8XCEbUhLc0s4YoBTjx9aI9vRJsTPcemst6T6pu0BFp5A",
  render_errors: [view: QWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Q.PubSub,
  live_view: [signing_salt: "gu7elorQ"]
)

config(:logger, :console, format: "$time $metadata[$level] $messag\n", metadata: [:request_id])
config(:phoenix, :json_library, Jason)
import_config("#{Mix.env()}.exs")
