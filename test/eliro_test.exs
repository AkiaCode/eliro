defmodule EliroTest do
  use ExUnit.Case
  doctest Eliro

  test "greets the world" do
    assert Eliro.hello() == :world
  end
end
