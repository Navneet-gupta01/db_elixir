defmodule Mix.Tasks.CreateFoo do
  use Mix.Task
  use Init.RepoInit

  @impl Mix.Task
  def run(_args) do
    Mix.shell().info("Creating foo Repository")
    {:ok, _} = Application.ensure_all_started(:postgrex)
    fetch_config(:db_foo) |> runTask |> handle_task
  end
end
