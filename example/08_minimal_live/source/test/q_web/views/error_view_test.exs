defmodule QWeb.ErrorViewTest do
use(QWeb.ConnCase, async: true)
import Phoenix.View
test("renders 404.html")
do
assert(((render_to_string(QWeb.ErrorView("404.html", [])))==("Notfound")))
end
test("renders 500.html")
do
assert(((render_to_string(QWeb.ErrorView("500.html", [])))==("Internal Server Error")))
end
end