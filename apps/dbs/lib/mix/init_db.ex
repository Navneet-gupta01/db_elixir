defmodule Mix.Tasks.CreateDbs do
  use Mix.Task
  use Init.RepoInit

  @impl Mix.Task
  def run(_args) do
    {:ok, _} = Application.ensure_all_started(:postgrex)
    Mix.shell().info("Creating foo Repository")
    fetch_config(:foo_database_conf) |> runTask |> handle_task
    Mix.shell().info("Creating bar Repository")
    fetch_config(:bar_database_conf) |> runTask |> handle_task
  end
end
