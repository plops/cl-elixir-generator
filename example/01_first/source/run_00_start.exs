#  comment
code_git_version = "75cdb3dde37d207864b9dd7a44eeff818261bce6"

code_repository =
  "https://github.com/plops/cl-elixir-generator/tree/master/example/01_first/source/run_00_start.py"

code_generation_time = "16:01:26 of Thursday, 2020-12-31 (GMT+1)"

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
