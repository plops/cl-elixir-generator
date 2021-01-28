defmodule QWeb.ChannelCase do
use ExUnit.CaseTemplate
using
do
quote
do
import Phoenix.ChannelTest
import QWeb.ChannelCase

@endpoint QWeb.Endpoint
end

end
setup(tags)
do
:ok = Ecto.Adapters.SQL.Sandbox.checkout(Q.Repo)
unless ( tags[:async] ) do
Ecto.Adapters.SQL.Sandbox.mode(Q.Repo, {:shared,self()})
end
:ok
end
end