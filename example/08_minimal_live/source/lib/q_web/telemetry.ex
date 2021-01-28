defmodule QWeb.Telemetry do
  use Supervisor
  import Telemetry.Metrics

  def start_link(arg) do
    Supervisor.start_link(__MODULE__, args, name: __MODULE__)
  end

  @impl true
  def init(_arg) do
    children = [{:telemetry_poller, measurements: periodic_measurements(), period: 10_000}]
    Supervisor.init(children, strategy: :one_for_one)
  end

  def metrics(
        list,
        summary("phoenix.endpoint.stop.duration", unit: {:native, :millisecond}),
        summary("phoenix.router_dispatch.stop.duration",
          tags: [:route],
          unit: {:native, :millisecond}
        ),
        summary("q.repo.query.total_time", unit: {:native, :millisecond}),
        summary("q.repo.query.decode_time", unit: {:native, :millisecond}),
        summary("q.repo.query.query_time", unit: {:native, :millisecond}),
        summary("q.repo.query.queue_time", unit: {:native, :millisecond}),
        summary("q.repo.query.idle_time", unit: {:native, :millisecond}),
        summary("vm.memory.total", unit: {:byte, :kilobyte}),
        summary("vm.total_run_queue_length.total"),
        summary("vm.total_run_queue_length.cpu"),
        summary("vm.total_run_queue_length.io")
      )

  defp periodic_measurements() do
    []
  end
end
