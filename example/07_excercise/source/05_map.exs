ExUnit.start()

defmodule MapTest do
  use ExUnit.Case

  def sample() do
    %{:foo => "bar", :baz => "quz"}
  end

  test "Map.get" do
    assert(Map.get(sample(), :foo) == "bar")
    assert(Map.get(sample(), :non_existent) == nil)
  end

  test "[]" do
    assert("bar" == sample()[:foo])
    assert(nil == sample()[:non_existent])
  end

  test "." do
    assert("bar" == sample().foo)
    assert_raise(KeyError, fn -> sample().non_existent end)
  end

  test "Map.fetch" do
    {:ok, val} = Map.fetch(sample(), :foo)
    assert("bar" == val)
    :error = Map.fetch(sample(), :non_existent)
  end

  test "Map.put" do
    assert(Map.put(sample(), :foo, "bob") == %{:foo => "bob", :baz => "quz"})
    assert(Map.put(sample(), :far, "bar") == %{:foo => "bob", :baz => "quz", :far => "bar"})
  end

  test "update map with pattern matching syntax" do
    assert(%{:foo => "bob", :baz => "quz"} == %{sample() | foo: 'bob'})
    assert_raise(KeyError, fn -> %{sample() | far: 'bob'} end)
  end

  test "Map.values" do
    assert(["bar", "quz"] == Enum.sort(Map.values(sample())))
  end
end
