defmodule Dbs.Program do
  def import do
    start = System.monotonic_time(:second)
    max_record_to_insert = Application.get_env(:dbs, :max_record)

    1..max_record_to_insert
    |> Stream.chunk_every(100_000, 100_000, [])
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
    |> Stream.chunk_every(100_000, 100_000, [])
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
  end
end
