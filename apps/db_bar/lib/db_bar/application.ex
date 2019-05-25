defmodule DbBar.Application do
  use Application

  def start(_, _) do
    DbBar.Supervisor.start_link()
  end
end
