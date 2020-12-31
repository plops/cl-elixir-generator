#  comment
code_git_version = "01ab648700ae213f571d65ecf1cda5a776a67c3c"

code_repository =
  "https://github.com/plops/cl-elixir-generator/tree/master/example/01_first/source/run_00_start.py"

code_generation_time = "20:58:47 of Thursday, 2020-12-31 (GMT+1)"

IO.puts(
  "#{__ENV__.file}:#{__ENV__.line} code_git_version=#{code_git_version} code_repository=#{
    code_repository
  } code_generation_time=#{code_generation_time}"
)

thing = :world
IO.puts("hello #{thing} from elixir")
IO.puts("#{__ENV__.file}:#{__ENV__.line} ((:apple)==(:orange))=#{:apple == :orange}")
add = fn a, b -> a + b end
IO.puts("#{__ENV__.file}:#{__ENV__.line} add.(1, 2)=#{add.(1, 2)}")
double = fn a -> add.(a, a) end
IO.puts("#{__ENV__.file}:#{__ENV__.line} double.(2)=#{double.(2)}")

IO.puts(
  "#{__ENV__.file}:#{__ENV__.line} inspect((([1, 2, 3])++([1, 2, true, 3])))=#{
    inspect([1, 2, 3] ++ [1, 2, true, 3])
  }"
)

IO.puts("#{__ENV__.file}:#{__ENV__.line} length([1, 2, 3])=#{length([1, 2, 3])}")

IO.puts(
  "#{__ENV__.file}:#{__ENV__.line} tuple_size({:hello,1,2,3,})=#{tuple_size({:hello, 1, 2, 3})}"
)

IO.puts(
  "#{__ENV__.file}:#{__ENV__.line} inspect({_a,_b,_c,}={:hello,1,2,})=#{
    inspect({_a, _b, _c} = {:hello, 1, 2})
  }"
)

IO.puts(
  "#{__ENV__.file}:#{__ENV__.line} inspect([((hhead) | (htail))]=[1, 2, 3])=#{
    inspect([hhead | htail] = [1, 2, 3])
  }"
)

IO.puts("#{__ENV__.file}:#{__ENV__.line} hhead=#{hhead} htail=#{htail}")
x = 1
IO.puts("#{__ENV__.file}:#{__ENV__.line} inspect({y,((x)),}={2,1,})=#{inspect({y, x} = {2, 1})}")
IO.puts("#{__ENV__.file}:#{__ENV__.line} inspect({y,y,}={1,1,})=#{inspect({y, y} = {1, 1})}")

case_test =
  case {1, 2, 3} do
    {4, 5, 6} -> "won't match"
    {1, x, 3} -> "will match and bind x=#{x}"
    _ -> "match otherwise"
  end

IO.puts("#{__ENV__.file}:#{__ENV__.line} case_test=#{case_test}")

cond_test =
  cond do
    2 * 2 == 3 -> "never true"
    true -> "else"
  end

IO.puts("#{__ENV__.file}:#{__ENV__.line} cond_test=#{cond_test}")

if nil do
  "won't be seen"
else
  "this will"
end

if true do
  "this works"
end

unless true do
  "never"
end

if true do
  "always"
end

if(false, do: :this, else: :that)
# bitstring
IO.puts("#{__ENV__.file}:#{__ENV__.line} ((<<42>>)===(<<42::8>>))=#{<<42>> === <<42::8>>}")

IO.puts(
  "#{__ENV__.file}:#{__ENV__.line} ((<<0::1,0::1,1::1,1::1>>)==(<<3,4>>))=#{
    <<0::1, 0::1, 1::1, 1::1>> == <<3, 4>>
  }"
)

IO.puts("#{__ENV__.file}:#{__ENV__.line} ((<<1>>)===(<<257>>))=#{<<1>> === <<257>>}")
IO.puts("#{__ENV__.file}:#{__ENV__.line} <<0,1,x>>=<<0,1,2>>=#{<<0, 1, x>> = <<0, 1, 2>>}")
IO.puts("#{__ENV__.file}:#{__ENV__.line} x=#{x}")

IO.puts(
  "#{__ENV__.file}:#{__ENV__.line} <<head::binary-size(2),rest::binary>>=<<0,1,2,3>>=#{
    <<head::binary-size(2), rest::binary>> = <<0, 1, 2, 3>>
  }"
)

IO.puts("#{__ENV__.file}:#{__ENV__.line} head=#{head} rest=#{rest}")

IO.puts(
  "#{__ENV__.file}:#{__ENV__.line} <<head,rest::binary>>=\"banana\"=#{
    <<head, rest::binary>> = "banana"
  }"
)

IO.puts("#{__ENV__.file}:#{__ENV__.line} head=#{head} rest=#{rest}")
# charlist
q = 'hello'
IO.puts("#{__ENV__.file}:#{__ENV__.line} q=#{q}")
# keyword lists
IO.puts(
  "#{__ENV__.file}:#{__ENV__.line} (([{:a,1,}, {:b,2,}])==([a: 1, b: 2]))=#{
    [{:a, 1}, {:b, 2}] == [a: 1, b: 2]
  }"
)

# map
map = %{:a => 1, 2 => :b}
# module
defmodule Math do
  def sum(a, b) do
    a + b
  end

  defp do_sum(a, b) do
    a + b
  end

  def zero?(0) do
    true
  end

  def zero?(x) when is_integer(x) do
    false
  end
end

IO.puts("#{__ENV__.file}:#{__ENV__.line} Math.sum(1, 2)=#{Math.sum(1, 2)}")

IO.puts(
  "#{__ENV__.file}:#{__ENV__.line} Math.zero?(0)=#{Math.zero?(0)} Math.zero?(1)=#{Math.zero?(1)}"
)

# named function with default argument
defmodule Concat do
  def join(a, b \\ nil, sep \\ " ")

  def join(a, b, _sep) when is_nil(b) do
    a
  end

  def join(a, b, sep) do
    a <> sep <> b
  end
end

IO.puts(
  "#{__ENV__.file}:#{__ENV__.line} Concat.join(\"hello\", \"world\")=#{
    Concat.join("hello", "world")
  }"
)

IO.puts(
  "#{__ENV__.file}:#{__ENV__.line} Concat.join(\"hello\", \"world\", \"_\")=#{
    Concat.join("hello", "world", "_")
  }"
)

IO.puts("#{__ENV__.file}:#{__ENV__.line} Concat.join(\"hello\")=#{Concat.join("hello")}")

defmodule MathRec do
  def sum_list([head | tail], accumulator) do
    sum_list(tail, head + accumulator)
  end

  def sum_list([], accumulator) do
    accumulator
  end
end

IO.puts(
  "#{__ENV__.file}:#{__ENV__.line} MathRec.sum_list([1, 2, 3], 0)=#{
    MathRec.sum_list([1, 2, 3], 0)
  }"
)

# pipe operator
odd? = fn x -> 0 != rem(x, 2) end

IO.puts(
  "#{__ENV__.file}:#{__ENV__.line} ((1..100_000)|>(Enum.map(fn x -> ((x)*(3))
end))|>(Enum.filter(odd?))|>(Enum.sum))=#{
    1..100_000 |> Enum.map(fn x -> x * 3 end) |> Enum.filter(odd?) |> Enum.sum()
  }"
)

IO.puts(
  "#{__ENV__.file}:#{__ENV__.line} ((1..100_000)|>(Stream.map(fn x -> ((x)*(3))
end))|>(Stream.filter(odd?))|>(Enum.sum))=#{
    1..100_000 |> Stream.map(fn x -> x * 3 end) |> Stream.filter(odd?) |> Enum.sum()
  }"
)
