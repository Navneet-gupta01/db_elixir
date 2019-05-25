defmodule DbFooTest do
  use ExUnit.Case
  doctest DbFoo

  test "greets the world" do
    assert DbFoo.hello() == :world
  end
end
