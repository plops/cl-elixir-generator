ExUnit.start
defmodule User do
defstruct([email: nil, password: nil])
end
defimpl String.Chars, for: User do
def to_string(%User{email: email}) do
    email
end
end
defmodule RecordTest do
use ExUnit.Case
defmodule ScopeTest do
use ExUnit.Case
require Record
Record.defrecord(:person, first_name: nil, last_name: nil, age: nil)
test "defrecordp" do
p=person(first_name: "Kai", last_name: "Morgan", age: 5)
assert(((p)==({:person,"Kai","Morgan",5,})))
end
end
def sample() do
    %User{:email: "kay@example.com",:password: "trains"}
end
test "defstruct" do
assert(((sample())==(%{:__struct__ => User,:email => "kai@example.com",:password => "trains"})))
end
end