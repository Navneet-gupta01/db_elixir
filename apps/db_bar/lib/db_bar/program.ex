defmodule DbBar.Program do
  def import_copy do
    start = System.monotonic_time(:second)
    max_record_to_insert = Application.get_env(:db_bar, :max_record)

    1..max_record_to_insert
    |> Stream.chunk_every(10000, 10000, [])
    |> Task.async_stream(
      fn rows ->
        Postgrex.transaction(
          Application.get_env(:db_foo, :databse_conf)[:name],
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
end
