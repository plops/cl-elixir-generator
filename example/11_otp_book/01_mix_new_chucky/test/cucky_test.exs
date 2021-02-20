defmodule ChuckyTest do
  use ExUnit.Case
  doctest Chucky

  test "greets the world" do
    assert(Chucky.hello() == :world)
  end
end
