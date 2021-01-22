defmodule Ping do
  def ping_async(ip, parent) do
    send(parent, ring_ping(ip))
  end

  def run_ping(ip) do
    try do
      {cmd_output, _} = System.cmd("ping", ping_args(ip))
      alive? = not Regex.match?(~r/100(\.0)?% packet loss/, cmd_output)
      {:ok, ip, alive?}
    rescue
      e -> {:error, ip, e}
    end
  end
end
