ExUnit.start
defmodule ListTest do
use ExUnit.Case
def sample() do
    ["Tim", "Jen", "Mac", "Kai"]
end
"sigil" do
assert(((sample())==(~w(Tim, Jen, Mac, Kai))))
end
end
CowInterrogator.interrogate