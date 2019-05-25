defmodule Init.RepoMigrate do
  defmacro __using__(_) do
    quote do
      import Init.RepoMigrate
      alias Init.RepoMigrate
    end
  end
end
