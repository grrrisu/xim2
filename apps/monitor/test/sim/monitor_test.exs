defmodule Sim.MonitorTest do
  use ExUnit.Case
  doctest Sim.Monitor

  test "greets the world" do
    assert Sim.Monitor.hello() == :world
  end
end
