Code.require_file "test_helper.exs", __DIR__

defmodule SectionTest do
  use ExUnit.Case

  import Section, only: [ add: 5 ]

  test "adding a race" do
    assert add("pleasanton", :swim, 500, :meters, 10/60 + 23/60/60) ==
     "your swim speed at the pleasanton triathlon is 2889.2 meters/hour"
  end
end
