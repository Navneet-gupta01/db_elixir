defmodule DbBarTest do
  use ExUnit.Case
  doctest DbBar

  test "greets the world" do
    assert DbBar.hello() == :world
  end
end
