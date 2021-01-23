defmodule Philosopher do
  defstruct(name: nil, ate: 0, thought: 0)
end

def simulate() do
  forks = [:fork0, :fork1, :fork2, :fork3, :fork4]
  table = spawn_link(Table, :manage_resource, [forks])
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
  end
end
