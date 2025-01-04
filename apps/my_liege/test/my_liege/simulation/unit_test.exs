defmodule MyLiege.Simulation.UnitTest do
  use ExUnit.Case, async: true
  alias MyLiege.Simulation.Unit

  @config %{needed: 5, output: 1}
  test "numbers" do
    assert {3, 0} == Unit.process_input(1, 2, @config)
    assert {0, 1} == Unit.process_input(2, 3, @config)
    assert {2, 1} == Unit.process_input(3, 4, @config)
    assert {1, 3} == Unit.process_input(12, 4, @config)
  end
end
