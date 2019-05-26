defmodule Dbs.Program do
  def import do
    start = System.monotonic_time(:second)
    max_record_to_insert = Application.get_env(:dbs, :max_record)

    1..max_record_to_insert
    |> Stream.chunk_every(10000, 10000, [])
    |> Task.async_stream(
      fn rows ->
        Enum.each(rows, fn x ->
          Postgrex.transaction(
            Application.get_env(:dbs, :foo_database_conf)[:name],
            fn conn ->
              Postgrex.query!(conn, "INSERT INTO source (a, b, c) values ($1, $2, $3)", [
                x,
                rem(x, 3),
                rem(x, 5)
              ])
            end,
            timeout: :infinity
          )
        end)
      end,
      max_concurrency: 8,
      timeout: :infinity
    )
    |> Stream.run()

    IO.puts("Time Consumed: #{System.monotonic_time(:second) - start}")
  end

  def import_copy do
    start = System.monotonic_time(:second)
    max_record_to_insert = Application.get_env(:dbs, :max_record)

    1..max_record_to_insert
    |> Stream.chunk_every(10000, 10000, [])
    |> Task.async_stream(
      fn rows ->
        Postgrex.transaction(
          Application.get_env(:dbs, :foo_database_conf)[:name],
          fn conn ->
            copy = Postgrex.stream(conn, "COPY source (a,b,c) FROM STDIN", [])

            rows
            |> Enum.map(fn x ->
              [to_string(x), ?\t, to_string(rem(x, 3)), ?\t, to_string(rem(x, 5)), ?\n]
            end)
            |> Enum.into(copy)
          end,
          timeout: :infinity
        )
      end,
      max_concurrency: 8,
      timeout: :infinity
    )
    |> Stream.run()

    IO.puts("Time Consumed: #{System.monotonic_time(:second) - start}")
  end

  def copy_from_foo_to_bar do
    start = System.monotonic_time(:second)

    Postgrex.transaction(
      Application.get_env(:dbs, :foo_database_conf)[:name],
      fn conn ->
        query = Postgrex.prepare!(conn, "", "COPY source to STDOUT")
        stream = Postgrex.stream(conn, query, [], max_rows: 10000)

        result_to_iodata = fn %Postgrex.Result{rows: rows} ->
          rows
        end

        Postgrex.transaction(
          Application.get_env(:dbs, :bar_database_conf)[:name],
          fn conn ->
            copy = Postgrex.stream(conn, "COPY dest (a,b,c) FROM STDIN", [])
            Enum.into(stream, copy, result_to_iodata)
          end,
          timeout: :infinity
        )
      end,
      timeout: :infinity
    )

    IO.puts("Time Consumed: #{System.monotonic_time(:second) - start}")
  end
end
