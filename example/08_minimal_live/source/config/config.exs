use Mix.Config
config(:live_view_studio, ecto_repos: [LiveViewStudio.Repo])

config(:live_view_studio, LiveViewStudioWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "Wy+j/oXYSmC2gLpNSuAz8XCEbUhLc0s4YoBTjx9aI9vRJsTPcemst6T6pu0BFp5A",
  render_errors: [view: LiveViewStudioWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: LiveViewStudio.PubSub,
  live_view: [signing_salt: "gu7elorQ"]
)

config(:logger, :console, format: "$time $metadata[$level] $messag\n", metadata: [:request_id])
config(:phoenix)
