defmodule DbFoo.Program do
  def import do
    1..1_000_000
    |> Stream.chunk_every(10000, 10000, [])
    |> Task.async_stream(
      fn rows ->
        Enum.each(rows, fn x ->
          Postgrex.transaction(
            Application.get_env(:db_foo, :databse_conf)[:name],
            fn conn ->
              IO.inspect(
                Postgrex.query!(conn, "INSERT INTO source (a, b, c) values ($1, $2, $3)", [
                  x,
                  rem(x, 3),
                  rem(x, 5)
                ])
              )
            end,
            timeout: :infinity
          )
        end)
      end,
      max_concurrency: 8,
      timeout: :infinity
    )
    |> Stream.run()
  end
end
