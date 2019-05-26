defmodule Dbs.ProgramTest do
  use ExUnit.Case
  @moduletag timeout: :infinity

  setup do
    Postgrex.query!(
      Application.get_env(:dbs, :foo_database_conf)[:name],
      truncate_foo_tables(),
      []
    )

    Postgrex.query!(
      Application.get_env(:dbs, :bar_database_conf)[:name],
      truncate_bar_tables(),
      []
    )

    :ok
  end

  describe "Dbs.Program" do
    test "import_copy/0 should populate Foo Database `source` table" do
      IO.puts("testing start")

      with _ <- Dbs.Program.import() do
        IO.puts("import done")

        %Postgrex.Result{rows: rows} =
          Postgrex.query!(
            Application.get_env(:dbs, :foo_database_conf)[:name],
            "SELECT count(*) FROM source",
            []
          )

        assert [[1000]] == rows
      end
    end

    test "copy_from_foo_to_bar/0 should populate Bar Database `dest` table using Foo's `source` table" do
      IO.puts("testing start")

      with _ <- Dbs.Program.import(), _ <- Dbs.Program.copy_from_foo_to_bar() do
        IO.puts("migration done")

        %Postgrex.Result{rows: rows} =
          Postgrex.query!(
            Application.get_env(:dbs, :bar_database_conf)[:name],
            "SELECT count(*) FROM dest",
            []
          )

        assert [[1000]] == rows
      end
    end
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
