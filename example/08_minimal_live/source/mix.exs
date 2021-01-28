defmodule Q.MixProject do
  use Mix.Project

  def project() do
    [
      :app,
      :q,
      :version,
      "0.1.0",
      :elixir,
      "~> 1.7",
      :elixirc_paths,
      elixirc_paths(Mix.env()),
      :compilers,
      [:phoenix, :gettext] ++ Mix.compilers(),
      :start_permanent,
      Mix.env() == :prod
    ]
  end
end
