Code.require_file "test_helper.exs", __DIR__

defmodule MongoTest do
  defrecord TestObject, name: nil, data: nil

  use ExUnit.Case

  setup_all do
    Mongo.init
    :ok
  end

  teardown_all do
    Mongo.shutdown
    :ok
  end

  test "pid returned if successful connection" do
    res = Mongo.connect('127.0.0.1', 27017)
    assert elem(res, 0) == :ok
    assert is_pid(elem(res, 1))
  end

  test "collection returned if successful connection" do
    {:ok, collection} = Mongo.get_collection('127.0.0.1', 27017, :test, :docs)
    assert is_pid(collection.pid)
    assert collection.db == :test
    assert collection.name == :docs 
  end

  test "saving an object in the db" do
    {:ok, collection} = Mongo.get_collection('127.0.0.1', 27017, :test, :docs)
    assert Mongo.delete(collection) == :ok
    to_save = TestObject.new name: "test", data: "this is fun"
    [stored] = Mongo.insert(collection, [to_save.to_keywords])
    record = TestObject.new stored
    assert record == to_save
    [stored] = Mongo.find(collection, [name: "test"])
    assert stored[:name] == "test"
    assert stored[:data] == "this is fun"
    assert is_binary(elem stored[:_id], 0)
    record = TestObject.new stored
    assert record == to_save
  end

  test "sorting results" do
    {:ok, collection} = Mongo.get_collection('127.0.0.1', 27017, :test, :docs)
    assert Mongo.delete(collection) == :ok
    to_save = TestObject.new name: "test", data: 2
    Mongo.insert(collection, [to_save.to_keywords])
    to_save_2 = TestObject.new name: "not_test", data: 1
    Mongo.insert(collection, [to_save_2.to_keywords])
    to_save_3 = TestObject.new name: "test", data: 3
    Mongo.insert(collection, [to_save_3.to_keywords])
    to_save_4 = TestObject.new name: "not_test", data: -1
    Mongo.insert(collection, [to_save_4.to_keywords])
    results = Mongo.find(collection, {:'$query', {}, :'$orderby', {:data, 1}})
    assert Enum.map(results, TestObject.new &1) == [to_save_4,to_save_2,to_save,to_save_3] 
  end

end
