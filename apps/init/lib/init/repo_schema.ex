defmodule Init.RepoSchema do
  defmacro __using__(_) do
    quote do
      import Init.RepoSchema
      alias Init.RepoSchema
    end
  end

  def fetch_config(db_conf_name, table_name) do
    conf = Application.get_all_env(:dbs)
    {Keyword.fetch!(conf, db_conf_name), table_name}
  end

  def runTask({db_conf, table_name}) do
    sql =
      ~s(CREATE TABLE "#{table_name}" \x28 a integer NOT NULL PRIMARY KEY, b integer NOT NULL, c integer NOT NULL \x29)

    {:ok, pid} = Task.Supervisor.start_link()

    {Task.Supervisor.async_nolink(pid, fn ->
       {:ok, conn} = Postgrex.start_link(db_conf)
       value = Postgrex.query(conn, sql, [], db_conf)
       GenServer.stop(conn)
       value
     end), table_name}
  end

  def handle_task({task, table_name}) do
    case Task.yield(task, 15_000) || Task.shutdown(task) do
      {:ok, {:ok, _result}} ->
        Mix.shell().info("table/schema #{table_name} created successfully")

      {:ok, {:error, %{postgres: %{code: :duplicate_table}}}} ->
        Mix.shell().info("table/schema #{table_name} already created")

      {:ok, {:error, error}} ->
        Mix.raise("The database for #{table_name} couldn't be created due to: #{inspect(error)}")

      {:exit, {%{__struct__: struct} = error, _}}
      when struct in [Postgrex.Error, DBConnection.Error] ->
        Mix.raise("The database for #{table_name} couldn't be created due to: #{inspect(error)}")

      {:exit, reason} ->
        Mix.raise(
          "The database for #{table_name} couldn't be created due to: #{
            inspect(RuntimeError.exception(Exception.format_exit(reason)))
          }"
        )

      nil ->
        Mix.raise(
          "The database for #{table_name} couldn't be created due to: #{
            inspect(RuntimeError.exception("command timed out"))
          }"
        )
    end
  end
end
