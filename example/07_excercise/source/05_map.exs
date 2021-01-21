ExUnit.start()

defmodule MapTest do
  use ExUnit.Case

  def sample() do
    dict(foo: string(bar), baz: string(quz))
  end

  test "Map.get" do
    assert(Map.get(sample(), :foo) == "bar")
  end
end
