defmodule CrafTest do
  use ExUnit.Case
  doctest Craf

  test "greets the world" do
    assert Craf.hello() == :world
  end
end
