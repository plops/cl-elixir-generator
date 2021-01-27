defmodule QWeb do
  def controller() do
    quote do
      use(Phoenix.Controller, namespace: QWeb)
      import Plug.Conn
      import QWeb.Gettext

      alias(QWeb.Router.Helpers, as: Routes)
    end
  end

  def view() do
    quote do
      use(Phoenix.View, root: "lib/q_web/templates", namespace: QWeb)

      import(Phoenix.Controller,
        only: [get_flash: 1, get_flash: 2, view_module: 1, view_template: 1]
      )

      unquote(view_helpers())
    end
  end

  def live_view() do
    quote do
      use(Phoenix.LiveView, layout: {QWeb.LayoutView, "live.html"})
      unquote(view_helpers())
    end
  end
end
