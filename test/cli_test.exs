Code.require_file "test_helper.exs", __DIR__

defmodule CLITest do
  use ExUnit.Case

  import CLI, only: [ parse_args: 1, parse_time: 1 ]

  test ":help returned by option parsing with -h and --help options" do assert parse_args(["-h", "anything"]) == :help
    assert parse_args(["--help", "anything"]) == :help
  end

  test "four values returned if three given" do
    assert parse_args(["pleasanton", "swim", "500", "meters", "1:40:15"]) == 
      { "pleasanton", :swim, 500, :meters, 1 + 40/60 + 15/60/60 }
  end

end
