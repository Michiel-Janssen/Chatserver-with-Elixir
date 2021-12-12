defmodule RootSupervisorTest do
  use ExUnit.Case
  doctest RootSupervisor

  test "greets the world" do
    assert RootSupervisor.hello() == :world
  end
end
