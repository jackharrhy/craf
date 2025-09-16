defmodule Craf do
  use Application

  @impl true
  def start(_type, _args) do
    Craf.Supervisor.start_link(name: Craf.Supervisor)
  end
end
