Code.require_file "test_helper.exs", __DIR__

defmodule RiakTest do
  defrecord TestObject, name: nil, data: nil

  use ExUnit.Case

  test "pid returned if successful connection" do
    res = Riak.connect('127.0.0.1', 8087)
    assert elem(res, 0) == :ok
    assert is_pid(elem(res, 1))
  end

  test "bucket returned if successful connection" do
    res = Riak.create_bucket('127.0.0.1', 8087, "test")
    assert elem(res, 0) == :ok
    assert is_pid(elem(res, 1).pid)
    assert elem(res, 1).name == "test"
  end

  test "saving an object in the db" do
    {:ok, bucket} = Riak.create_bucket('127.0.0.1', 8087, "test")
    to_save = TestObject.new name: "test", data: "this is fun"
    assert Riak.set(bucket, "test_data", to_save) == :ok
    assert Riak.get(bucket, "test_data") == to_save
  end

end
