ExUnit.start()

defmodule User do
  defstruct(email: nil, password: nil)
end

defimpl String.Chars, for: User do
  def to_string(%User{email: email}) do
    email
  end
end
