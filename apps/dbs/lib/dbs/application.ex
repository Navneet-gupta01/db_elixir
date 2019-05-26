defmodule Dbs.Application do
  use Application

  def start(_, _) do
    Dbs.Supervisor.start_link()
  end
end
