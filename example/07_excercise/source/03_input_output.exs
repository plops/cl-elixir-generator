defmodule CowInterrogator do
  @doc """
  Gets name from standard IO
  """
  def get_name() do
    IO.gets("what is your name? ") |> String.trim()
  end

  def get_cow_lover() do
    IO.getn("do you like cows? [y|n]", 1)
  end

  def interrogate() do
    name = get_name()

    case String.downcase(get_cow_lover()) do
      "y" ->
        IO.puts("great! here is a cow for you #{name}:")
        IO.puts(cow_art())

      "n" ->
        IO.puts("that is a shame, #{name}.")

      _ ->
        IO.puts("you should have entered 'y' or 'n'.")
    end
  end

  def cow_art() do
    path = Path.expand("support/cow.txt", __DIR__)

    case File.read(path) do
      {:ok, art} ->
        art

      {:error, _} ->
        IO.puts("error: cow.txt file not found")
        System.halt(1)
    end
  end
end

ExUnit.start()

defmodule InputOutputTest do
  use ExUnit.Case
  import String

  test "checks if cow_art returns string from support/cow.txt" do
    art = CowInterrogator.cow_art()
    assert(trim(art) |> first == "(")
  end
end

CowInterrogator.interrogate()
