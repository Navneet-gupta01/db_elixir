defmodule Mix.Tasks.MigrateFoo do
  use Mix.Task
  use Init.RepoSchema

  @impl Mix.Task
  def run(_args) do
    Mix.shell().info("Migrating foo's source schema")
    {:ok, _} = Application.ensure_all_started(:postgrex)
    fetch_config(:db_foo, :source) |> runTask |> handle_task
  end
end
