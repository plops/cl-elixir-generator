defmodule QWeb.PageLiveTest do
  use QWeb.ConnCase
  import Phoenix.LiveViewTest
  test("disconnected and connected render", %{:conn => conn})
end
