defmodule Mix.Tasks.MigrateDbs do
  use Mix.Task
  use Init.RepoSchema

  @impl Mix.Task
  def run(_args) do
    {:ok, _} = Application.ensure_all_started(:postgrex)
    Mix.shell().info("Migrating foo's source schema")
    fetch_config(:foo_database_conf, :source) |> runTask |> handle_task
    Mix.shell().info("Migrating bar's dest schema")
    fetch_config(:bar_database_conf, :dest) |> runTask |> handle_task
  end
end
