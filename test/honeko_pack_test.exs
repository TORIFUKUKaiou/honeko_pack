defmodule HonekoPackTest do
  use ExUnit.Case
  doctest HonekoPack

  test "greets the world" do
    assert HonekoPack.hello() == :world
  end
end
