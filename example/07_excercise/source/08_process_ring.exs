defmodule Pinger do
  def ping(echo, limit) do
    receive do
      {[next | rest], msg, count} when count <= limit ->
        IO.puts("#{__ENV__.file}:#{__ENV__.line} inspect(msg)=#{inspect(msg)} count=#{count}")
        :timer.sleep(1000)
        send(next, {rest ++ [next], echo, count + 1})
        ping(echo, limit)

      {[next | rest], _, _} ->
        send(next, {rest, :ok})

      {[next | rest], :ok} ->
        send(next, {rest, :ok})
    end
  end
end

defmodule Spawner do
  def start() do
    limit = 5
    {foo, _foo_monitor} = spawn_monitor(Pinger, :ping, ["foo", limit])
    {bar, _bar_monitor} = spawn_monitor(Pinger, :ping, ["bar", limit])
    {baz, _baz_monitor} = spawn_monitor(Pinger, :ping, ["baz", limit])
    send(foo, {[bar, baz, foo], "start", 0})
    wait([foo, bar, baz])
  end

  @doc "Waits for all processes to finish before exiting."
  def wait(pids) do
    IO.puts("#{__ENV__.file}:#{__ENV__.line} \"wait\"=#{"wait"} inspect(pids)=#{inspect(pids)}")

    receive do
      {:DOWN, _, _, pid, _} ->
        IO.puts("#{__ENV__.file}:#{__ENV__.line} \"quit\"=#{"quit"} inspect(pid)=#{inspect(pid)}")
        pids = List.delete(pids, pid)

        unless Enum.empty?(pids) do
          wait(pids)
        end
    end
  end
end

Spawner.start()
