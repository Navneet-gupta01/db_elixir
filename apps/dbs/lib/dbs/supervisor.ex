defmodule Dbs.Supervisor do
  def start_link do
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

    Supervisor.start_link(
      children,
      strategy: :one_for_one
    )
  end
end
