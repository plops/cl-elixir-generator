defmodule Ping do
  def ping_async(ip, parent) do
    send(parent, run_ping(ip))
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

  def ping_args(ip) do
    ["-c", "1", "-w", "5", "-s", "1", ip]
  end
end

defmodule Subnet do
  def ping(subnet) do
    all = ips(subnet)
    Enum.each(all, fn ip -> Task.start(Ping, :ping_async, [ip, self()]) end)
    wait(%{}, Enum.count(all))
  end

  @doc "Given class-C subnet like 192.168.1.x return list of all 254 contained ips"
  def ips(subnet) do
    subnet = Regex.run(~r/^\d+\.\d+\.\d+\./, subnet) |> Enum.at(0)
    Enum.to_list(1..254) |> Enum.map(fn i -> "#{subnet}#{i}" end)
  end

  defp wait(results, 0) do
    results
  end

  defp wait(results, remaining) do
    receive do
      {:ok, ip, pingable?} ->
        results = Map.put(results, ip, pingable?)
        wait(results, remaining - 1)

      {:error, ip, error} ->
        IO.puts("#{__ENV__.file}:#{__ENV__.line} inspect(error)=#{inspect(error)} ip=#{ip}")
        wait(results, remaining - 1)
    end
  end
end

case System.argv() do
  [subnet] ->
    results = Subnet.ping(subnet)

    results
    |> Enum.filter(fn {_ip, exists} -> exists end)
    |> Enum.map(fn {ip, _} -> ip end)
    |> Enum.sort()
    |> Enum.join("\n")
    |> IO.puts()

  _ ->
    ExUnit.start()

    defmodule SubnetTest do
      use ExUnit.Case

      test "ips" do
        ips = Subnet.ips("192.168.1.x")
        assert(Enum.count(ips) == 254)
        assert("192.168.1.1" == Enum.at(ips, 0))
        assert("192.168.1.254" == Enum.at(ips, 253))
      end
    end
end
