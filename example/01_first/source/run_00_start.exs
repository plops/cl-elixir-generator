#  comment
code_git_version = "2592f116cd2090447e8911f62bd2d52f38a4f013"

code_repository =
  "https://github.com/plops/cl-elixir-generator/tree/master/example/01_first/source/run_00_start.py"

code_generation_time = "09:04:54 of Friday, 2021-01-01 (GMT+1)"

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
  "#{__ENV__.file}:#{__ENV__.line} ((1..100_000)|>(Enum.map(fn (x) -> ((x)*(3))
end))|>(Enum.filter(odd?))|>(Enum.sum))=#{
    1..100_000 |> Enum.map(fn x -> x * 3 end) |> Enum.filter(odd?) |> Enum.sum()
  }"
)

IO.puts(
  "#{__ENV__.file}:#{__ENV__.line} ((1..100_000)|>(Stream.map(fn (x) -> ((x)*(3))
end))|>(Stream.filter(odd?))|>(Enum.sum))=#{
    1..100_000 |> Stream.map(fn x -> x * 3 end) |> Stream.filter(odd?) |> Enum.sum()
  }"
)

# spawn
pid = spawn(fn -> 1 + 2 end)

IO.puts(
  "#{__ENV__.file}:#{__ENV__.line} inspect(pid)=#{inspect(pid)} Process.alive?(pid)=#{
    Process.alive?(pid)
  }"
)

IO.puts(
  "#{__ENV__.file}:#{__ENV__.line} inspect(self())=#{inspect(self())} Process.alive?(self())=#{
    Process.alive?(self())
  }"
)

# messages
parent = self()
spawn(fn -> send(parent, {:hello, self()}) end)

receive do
  {:hello, pid} ->
    IO.puts(
      "#{__ENV__.file}:#{__ENV__.line} \"got hello from #{inspect(pid)}\"=#{
        "got hello from #{inspect(pid)}"
      }"
    )
end

# state
defmodule KV do
  @moduledoc """
  module example for state
  """
  def start_link() do
    Task.start_link(fn -> loop(%{}) end)
  end

  defp loop(map) do
    receive do
      {:get, key, caller} ->
        send(caller, Map.get(map, key))
        loop(map)

      {:put, key, value} ->
        loop(Map.put(map, key, value))
    end
  end
end

IO.puts(
  "#{__ENV__.file}:#{__ENV__.line} inspect({:ok,pid,}=KV.start_link())=#{
    inspect({:ok, pid} = KV.start_link())
  }"
)

IO.puts(
  "#{__ENV__.file}:#{__ENV__.line} inspect(send(pid, {:get,:hello,self(),}))=#{
    inspect(send(pid, {:get, :hello, self()}))
  }"
)

# struct
defmodule User do
  defstruct(name: "John", age: 27)
end

# protocol
defprotocol Utility do
  @spec type(t) :: String.t()
  def type(value)
end

defimpl Utility, for: Atom do
  def type(_value) do
    "Atom"
  end
end

defimpl Utility, for: BitString do
  def type(_value) do
    "BitString"
  end
end

defimpl Utility, for: Float do
  def type(_value) do
    "Float"
  end
end

defimpl Utility, for: Function do
  def type(_value) do
    "Function"
  end
end

defimpl Utility, for: Integer do
  def type(_value) do
    "Integer"
  end
end

defimpl Utility, for: List do
  def type(_value) do
    "List"
  end
end

defimpl Utility, for: Map do
  def type(_value) do
    "Map"
  end
end

defimpl Utility, for: PID do
  def type(_value) do
    "PID"
  end
end

defimpl Utility, for: Port do
  def type(_value) do
    "Port"
  end
end

defimpl Utility, for: Reference do
  def type(_value) do
    "Reference"
  end
end

defimpl Utility, for: Tuple do
  def type(_value) do
    "Tuple"
  end
end

IO.puts(
  "#{__ENV__.file}:#{__ENV__.line} inspect(Utility.type(\"foo\"))=#{inspect(Utility.type("foo"))}"
)

IO.puts(
  "#{__ENV__.file}:#{__ENV__.line} inspect(Utility.type(123))=#{inspect(Utility.type(123))}"
)

# comprehension
for n <- [1, 2, 3, 4] do
  n * n
end

multiple_of_3? = fn n -> rem(n, 3) == 0 end

for n <- [1, 2, 3, 4], multiple_of_3?.(n) do
  n * n
end

dirs = ["/home", "/tmp"]

for dir <- dirs, file <- File.ls!(dir), path = Path.join(dir, file), File.regular?(path) do
  File.stat!(path).size
end

# bitstring generator
pixels = <<213, 45, 132, 64, 32, 12, 45, 31, 9, 0, 0, 231>>

for <<r::8, g::8, b::8 <- pixels>> do
  {r, g, b}
end

# into .. remove whitespace
for <<c <- "hello world ">>, c != ?\s, into: "" do
  <<c>>
end

# into .. transform map
for {key, val} <- %{"a" => 1, "b" => 2}, into: %{} do
  {key, val * val}
end
