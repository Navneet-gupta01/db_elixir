defmodule Dbs.Supervisor do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_arg) do
    children = [
      %{
        id: :foo_db_pool,
        start: {Postgrex, :start_link, [Application.get_env(:dbs, :foo_database_conf)]}
      },
      %{
        id: :bar_db_pool,
        start: {Postgrex, :start_link, [Application.get_env(:dbs, :bar_database_conf)]}
      },
      Dbs.Web
    ]

    Supervisor.init(
      children,
      strategy: :one_for_one
    )
  end
end
