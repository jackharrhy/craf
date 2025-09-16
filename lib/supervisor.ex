defmodule Craf.Supervisor do
  use Supervisor

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, :ok, opts)
  end

  @impl true
  def init(:ok) do
    children = [
      {Task.Supervisor, name: Craf.TaskSupervisor},
      Supervisor.child_spec({Task, fn -> Craf.Server.run() end}, id: "server")
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
