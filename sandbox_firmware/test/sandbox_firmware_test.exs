defmodule SandboxFirmwareTest do
  use ExUnit.Case
  doctest SandboxFirmware

  test "greets the world" do
    assert SandboxFirmware.hello() == :world
  end
end
