ExUnit.start()

defmodule ListTest do
  use ExUnit.Case

  def sample() do
    ["Tim", "Jen", "Mac", "Kai"]
  end

  test "sigil" do
    assert(sample() == ~w(Tim Jen Mac Kai))
  end

  test "head" do
    [head | _] = sample()
    assert(head == "Tim")
  end

  test "tail" do
    [_ | tail] = sample()
    assert(tail == ~w(Jen Mac Kai))
  end

  test "last item" do
    assert("Kai" == List.last(sample()))
  end

  test "delete item" do
    assert(~w(Tim Jen Kai) == List.delete(sample(), "Mac"))
    assert([1, 2, 3] == List.delete([1, 2, 2, 3], 2))
  end

  test "List.fold" do
    list = [20, 10, 5, 2.50]
    sum = List.foldr(list, 0, fn num, sum -> num + sum end)
    assert(37.50 == sum)
  end

  test "Enum.reduce" do
    list = [20, 10, 5, 2.50]
    sum = Enum.reduce(list, 0, fn num, sum -> num + sum end)
    assert(37.50 == sum)
  end

  test "wrap" do
    assert(sample() == List.wrap(sample()))
    assert([1] == List.wrap(1))
    assert([] == List.wrap([]))
    assert([] == List.wrap(nil))
  end

  test "list-comprehension" do
    some =
      for n <- sample(), String.first(n) < "M" do
        n <> "Morgan"
      end

    assert(some == ["Jen Morgan", "Kai Morgan"])
  end

  test "manual-reverse-speed" do
    {microsec, reversed} =
      :timer.tc(fn -> Enum.reduce(1..1_000_000, [], fn i, l -> List.insert_at(l, 0, i) end) end)

    assert(reversed == Enum.to_list(1_000_000..1))
    IO.puts("#{__ENV__.file}:#{__ENV__.line} microsec=#{microsec}")
  end

  test "Enum.reverse-speed" do
    {microsec, reversed} = :timer.tc(fn -> Enum.reverse(1..1_000_000) end)
  end
end
