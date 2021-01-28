defmodule QWeb.Router do
  use(QWeb, :router)

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_live_flash)
    plug(:put_root_layout, {QWeb.LayoutView, :root})
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
  end

  pipeline :api do
    plug(:accepts, ["json"])
  end

  scope("/", QWeb) do
    pipe_through(:browser)
    live("/", PageLive, :index)
  end

  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope("/") do
      pipe_through(:browser)
      live_dashboard("/dashboard", metrics: QWeb.Telemetry)
    end
  end
end
