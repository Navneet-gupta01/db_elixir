defmodule Dbs.Application do
  use Application

  def start(_, _) do
    import Supervisor.Spec

    children = [
      supervisor(Dbs.Supervisor, [])
    ]

    opts = [strategy: :one_for_one, name: __MODULE__]
    Supervisor.start_link(children, opts)
  end
end
