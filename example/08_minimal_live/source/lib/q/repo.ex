defmodule Q.Repo do
  use(Ecto.Repo, otp_app: :q, adapter: Ecto.Adapters.Postgres)
end
