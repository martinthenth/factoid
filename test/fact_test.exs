defmodule FactTest do
  use ExUnit.Case
  use Fact

  describe "__using__/1" do
    test "false" do
      assert false
    end
  end
end
