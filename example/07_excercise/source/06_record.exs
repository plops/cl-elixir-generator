ExUnit.start()

defmodule User do
  defstruct(email: nil, password: nil)
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
      p = person(first_name: "Kai", last_name: "Morgan", age: 5)
      assert(p == {:person, "Kai", "Morgan", 5})
    end
  end

  def sample() do
    %User{email: "kay@example.com", password: "trains"}
  end

  test "property" do
    assert(sample().email == "kai@example.com")
  end

  test "update" do
    u = sample()
    u2 = %User{u | email: "tim@example.com"}
    assert(u2 == %User{email: "tim@example.com", password: "trains"})
  end

  test "protocol" do
    assert(to_string(sample()) == "kai@example.com")
  end
end
