defmodule Dbs.Web do
  use Plug.Router
  use Plug.ErrorHandler

  plug(:match)
  plug(:dispatch)

  def child_spec(_arg) do
    Plug.Cowboy.child_spec(
      scheme: :http,
      options: [port: Application.fetch_env!(:dbs, :port)],
      plug: __MODULE__
    )
  end

  get("/", do: send_resp(conn, 200, "Great Router Configured"))

  get("/dbs/foo/tables/source") do
    conn =
      conn
      |> put_resp_content_type("text/event-stream")
      |> send_chunked(200)

    header = "a,b,c"
    conn |> chunk("#{header}\n")

    send_next_foo(conn)
  end

  get("/dbs/bar/tables/dest") do
    conn =
      conn
      |> put_resp_content_type("text/event-stream")
      |> send_chunked(200)

    header = "a, b, c"
    conn |> chunk("#{header}\n")

    send_next_bar(conn)
  end

  def send_next_foo(conn) do
    Postgrex.transaction(
      Application.get_env(:dbs, :foo_database_conf)[:name],
      fn pconn ->
        Postgrex.stream(
          pconn,
          "SELECT a, b, c FROM source order by a",
          [],
          max_rows: 1
        )
        |> Stream.map(fn %Postgrex.Result{rows: rows} ->
          Enum.reduce_while(rows, conn, fn [a, b, c], conn ->
            case chunk(conn, "#{a}, #{b}, #{c}\n") do
              {:ok, conn} ->
                {:cont, conn}

              _ ->
                {:halt, conn}
            end
          end)
        end)
        |> Stream.run()
      end,
      timeout: :infinity
    )
  end

  def send_next_bar(conn) do
    Postgrex.transaction(
      Application.get_env(:dbs, :bar_database_conf)[:name],
      fn pconn ->
        Postgrex.stream(
          pconn,
          "SELECT a, b, c FROM dest order by a",
          [],
          max_rows: 1
        )
        |> Stream.map(fn %Postgrex.Result{rows: rows} ->
          Enum.reduce_while(rows, conn, fn [a, b, c], conn ->
            case chunk(conn, "#{a}, #{b}, #{c}\n") do
              {:ok, conn} ->
                {:cont, conn}

              _ ->
                {:halt, conn}
            end
          end)
        end)
        |> Stream.run()
      end,
      timeout: :infinity
    )
  end

  match _ do
    Plug.Conn.send_resp(conn, 404, "not found")
  end

  def handle_errors(conn, %{kind: :error, reason: _reason, stack: _stack}) do
    send_resp(conn, 400, Jason.encode!(%{error: "Invalid Argument"}))
  end

  def handle_errors(conn, %{kind: _kind, reason: _reason, stack: _stack}) do
    send_resp(conn, conn.status, Jason.encode!(%{error: "Something went wrong"}))
  end
end
