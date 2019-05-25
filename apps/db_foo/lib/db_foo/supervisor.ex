defmodule DbFoo.Supervisor do
  def start_link do
    Supervisor.start_link(
      [
        {Postgrex, Application.get_env(:db_foo, :databse_conf)}
      ],
      strategy: :one_for_one
    )
  end
end
