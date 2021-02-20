defmodule Chucky.Server do
  use GenServer

  def start_link() do
    GenServer.start_link(__MODULE__, [], name: {:global, __MODULE__})
  end
end
