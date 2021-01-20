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
end
