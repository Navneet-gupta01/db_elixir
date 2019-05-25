defmodule DbsTest do
  use ExUnit.Case
  doctest Dbs

  test "greets the world" do
    assert Dbs.hello() == :world
  end
end
