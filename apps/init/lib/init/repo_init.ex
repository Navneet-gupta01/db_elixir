defmodule Init.RepoInit do
  @doc false
  defmacro __using__(_) do
    quote do
      import unquote(__MODULE__)
      alias unquote(__MODULE__)
    end
  end

  @default_maintenance_database "postgres"

  def fetch_config(db_conf_name) do
    conf = Application.get_all_env(:dbs)
    db_conf = Keyword.fetch!(conf, db_conf_name)
    database = Keyword.fetch!(db_conf, :database)
    {database, Keyword.put(db_conf, :database, @default_maintenance_database)}
  end

  def runTask({database_to_create, db_conf}) do
    sql = ~s(CREATE DATABASE "#{database_to_create}" ENCODING UTF8)
    {:ok, pid} = Task.Supervisor.start_link()

    {Task.Supervisor.async_nolink(pid, fn ->
       {:ok, conn} = Postgrex.start_link(db_conf)
       value = Postgrex.query(conn, sql, [], db_conf)
       GenServer.stop(conn)
       value
     end), database_to_create}
  end

  def handle_task({task, database_to_create}) do
    case Task.yield(task, 15_000) || Task.shutdown(task) do
      {:ok, {:ok, _result}} ->
        Mix.shell().info("database #{database_to_create} created successfully")

      {:ok, {:error, %{postgres: %{code: :duplicate_database}}}} ->
        Mix.shell().info("database #{database_to_create} already created")

      {:ok, {:error, error}} ->
        Mix.raise(
          "The database for #{database_to_create} couldn't be created due to: #{inspect(error)}"
        )

      {:exit, {%{__struct__: struct} = error, _}}
      when struct in [Postgrex.Error, DBConnection.Error] ->
        Mix.raise(
          "The database for #{database_to_create} couldn't be created due to: #{inspect(error)}"
        )

      {:exit, reason} ->
        Mix.raise(
          "The database for #{database_to_create} couldn't be created due to: #{
            inspect(RuntimeError.exception(Exception.format_exit(reason)))
          }"
        )

      nil ->
        Mix.raise(
          "The database for #{database_to_create} couldn't be created due to: #{
            inspect(RuntimeError.exception("command timed out"))
          }"
        )
    end
  end
end
