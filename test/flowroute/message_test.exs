defmodule Flowroute.MessageTest do
  use ExUnit.Case
  alias Flowroute.Message
  doctest Flowroute.Message

  test "greets the world" do
    assert Flowroute.hello() == :world
  end
end
