defmodule QWeb do
  def controller() do
    quote do
      use(Phoenix.Controller, namespace: QWeb)
    end
  end
end
