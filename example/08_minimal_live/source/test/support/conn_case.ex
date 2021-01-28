defmodule QWeb.ConnCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      import Phoenix.Conn
      import Phoenix.ConnTest
      import QWeb.ConnCase

      alias(QWeb.Router.Helpers, as: Routes)
      @endpoint QWeb.Endpoint
    end
  end

  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Q.Repo)

    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(Q.Repo, {:shared, self()})
    end

    {:ok, conn: Phoenix.ConnTest.build_conn()}
  end
end
