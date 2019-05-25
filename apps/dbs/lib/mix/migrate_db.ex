defmodule Mix.Tasks.MigrateBar do
  use Mix.Task
  use Init.RepoSchema

  @impl Mix.Task
  def run(_args) do
    Mix.shell().info("Migrating bar's dest schema")
    {:ok, _} = Application.ensure_all_started(:postgrex)
    fetch_config(:db_bar, :dest) |> runTask |> handle_task
    fetch_config(:db_foo, :dest) |> runTask |> handle_task
  end
end
