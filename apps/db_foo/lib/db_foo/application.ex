defmodule DbFoo.Application do
  use Application

  def start(_, _) do
    DbFoo.Supervisor.start_link()
  end
end
