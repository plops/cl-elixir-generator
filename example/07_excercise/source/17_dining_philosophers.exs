defmodule Table do
  defmodule Philosopher do
    defstruct(name: nil, ate: 0, thought: 0)
  end

  def simulate() do
    forks = [:fork0, :fork1, :fork2, :fork3, :fork4]
    table = spawn_link(Table, :manage_resources, [forks])
    spawn(Dine, :dine, [%Philosopher{name: "Aris"}, table])
    spawn(Dine, :dine, [%Philosopher{name: "Kant"}, table])
    spawn(Dine, :dine, [%Philosopher{name: "Spin"}, table])
    spawn(Dine, :dine, [%Philosopher{name: "Marx"}, table])
    spawn(Dine, :dine, [%Philosopher{name: "Russ"}, table])

    receive do
      _ -> :ok
    end
  end

  def manage_resources(forks, waiting \\ []) do
    if 0 < length(waiting) do
      names =
        for {_, phil} <- waiting do
          phil.name
        end

      IO.puts("#{__ENV__.file}:#{__ENV__.line} length(waiting)=#{length(waiting)} names=#{names}")

      if 2 <= length(forks) do
        [{pid, _} | waiting] = waiting
        [fork1, fork2 | forks] = forks
        send(pid, {:eat, [fork1, fork2]})
      end

      receive do
        {:sit_down, pid, phil} ->
          manage_resources(forks, [{pid, phil} | waiting])

        {:give_up_seat, free_forks, _} ->
          forks = free_forks ++ forks
          IO.puts("#{__ENV__.file}:#{__ENV__.line} length(forks)=#{length(forks)}")
          manage_resources(forks, waiting)
      end
    end
  end

  defmodule Dine do
    def dine(phil, table) do
      send(table, {:sit_down, self, phil})

      receive do
        {:eat, forks} ->
          phil = eat(phil, forks, table)
          phil = think(phil, table)
      end

      dine(phil, table)
    end

    def eat(phil, forks, table) do
      phil = %{phil | ate: phil.ate + 1}

      IO.puts(
        "#{__ENV__.file}:#{__ENV__.line} phil.name=#{phil.name} \"eating\"=#{"eating"} phil.ate=#{
          phil.ate
        }"
      )

      :timer.sleep(:random.uniform(1_000))

      IO.puts(
        "#{__ENV__.file}:#{__ENV__.line} phil.nam=#{phil.nam} \"done eating\"=#{"done eating"}"
      )

      send(table, {:give_up_seat, forks, phil})
      phil
    end

    def think(phil, _) do
      IO.puts(
        "#{__ENV__.file}:#{__ENV__.line} phil.name=#{phil.name} \"thinking\"=#{"thinking"} phil.thought=#{
          phil.thought
        }"
      )

      :timer.sleep(:random.uniform(1000))
      phil = %{phil | thought: phil.thought + 1}
    end
  end
end

:random.seed(:erlang.now())
Table.simulate()
