#  comment
code_git_version = "54f95c2248fc0b85674be905ca6b50e5479cb9bf"

code_repository =
  "https://github.com/plops/cl-elixir-generator/tree/master/example/01_first/source/run_00_start.py"

code_generation_time = "14:52:04 of Thursday, 2020-12-31 (GMT+1)"

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

# bitstring
IO.puts("#{__ENV__.file}:#{__ENV__.line} ((<<42>>)===(<<42::8>>))=#{<<42>> === <<42::8>>}")

IO.puts(
  "#{__ENV__.file}:#{__ENV__.line} ((<<0::1,0::1,1::1,1::1>>)==(<<3,4>>))=#{
    <<0::1, 0::1, 1::1, 1::1>> == <<3, 4>>
  }"
)
