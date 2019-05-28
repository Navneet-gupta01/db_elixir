defmodule Dbs.Storage do
  def reset! do
    :ok = Application.stop(:dbs)
    reset_foo()
    reset_bar()
    {:ok, _} = Application.ensure_all_started(:dbs)
  end

  defp reset_foo do
    foo_config = Application.get_env(:dbs, :foo_database_conf)
    {:ok, conn} = Postgrex.start_link(foo_config)
    Postgrex.query!(conn, truncate_foo_tables(), [])
    _ = Process.exit(conn, :kill)
  end

  defp reset_bar do
    bar_config = Application.get_env(:dbs, :bar_database_conf)
    {:ok, conn} = Postgrex.start_link(bar_config)
    Postgrex.query!(conn, truncate_bar_tables(), [])
    _ = Process.exit(conn, :kill)
  end

  defp truncate_foo_tables do
    """
    TRUNCATE TABLE
      source
    RESTART IDENTITY;
    """
  end

  defp truncate_bar_tables do
    """
    TRUNCATE TABLE
      dest
    RESTART IDENTITY;
    """
  end
end
