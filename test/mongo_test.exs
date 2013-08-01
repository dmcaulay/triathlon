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
    to_save = {:name, "test", :data, "this is fun"}
    assert Mongo.delete(collection) == :ok
    assert Mongo.insert(collection, [to_save])
    [{:name, name, :data, data, _, _}] = Mongo.find(collection, {:name, "test"})
    assert name == "test"
    assert data == "this is fun"
  end

  # test "deleting an object in the db" do
  #   {:ok, bucket} = Riak.create_bucket('127.0.0.1', 8087, "test")
  #   to_save = TestObject.new name: "test", data: "this is fun"
  #   assert Riak.set(bucket, "test_data", to_save) == :ok
  #   assert Riak.get(bucket, "test_data") == to_save
  #   assert Riak.delete(bucket, "test_data") == :ok
  #   assert Riak.get(bucket, "test_data") == {:error,:notfound}
  # end

  # test "adding secondary indexes on a bucket" do
  #   {:ok, bucket} = Riak.create_bucket('127.0.0.1', 8087, "test")
  #   bucket = Riak.set_indexes bucket, binary_index: "name"
  #   to_save = TestObject.new name: "test", data: "this is fun"
  #   assert Riak.set(bucket, "test_data", to_save) == :ok
  #   to_save_2 = TestObject.new name: "not_test", data: "this is not fun"
  #   assert Riak.set(bucket, "test_data_2", to_save_2) == :ok
  #   to_save_3 = TestObject.new name: "test", data: "this is amazing"
  #   assert Riak.set(bucket, "test_data_3", to_save_3) == :ok
  #   to_save_4 = TestObject.new name: "test", data: "this is new"
  #   assert Riak.set(bucket, "test_data_4", to_save_4) == :ok
  #   {:ok, results, _} = Riak.find(bucket, {'name', "test"})
  #   assert results == [to_save,to_save_3,to_save_4] 
  #   {:ok, results, _} = Riak.find(bucket, {'name', "test"}, max_results: 2)
  #   assert results == [to_save,to_save_3]
  #   # {:ok, results, _} = Riak.find(bucket, {'name', "test"}, continuation: continuation)
  #   # assert results == [to_save_4]
  # end

  # test "adding secondary indexes on a bucket with sorting" do
  #   {:ok, bucket} = Riak.create_bucket('127.0.0.1', 8087, "test")
  #   bucket = Riak.set_indexes bucket, binary_index: "name", integer_index: "data"
  #   to_save = TestObject.new name: "test", data: 2
  #   assert Riak.set(bucket, "test_data", to_save) == :ok
  #   to_save_2 = TestObject.new name: "not_test", data: 1
  #   assert Riak.set(bucket, "test_data_2", to_save_2) == :ok
  #   to_save_3 = TestObject.new name: "test", data: 3
  #   assert Riak.set(bucket, "test_data_3", to_save_3) == :ok
  #   to_save_4 = TestObject.new name: "not_test", data: -1
  #   assert Riak.set(bucket, "test_data_4", to_save_4) == :ok
  #   {:ok, results, _} = Riak.find(bucket, {'data', 1})
  #   assert results == [to_save_2]
  #   {:ok, results, _} =  Riak.find(bucket, {'data', -2, 10})
  #   assert results == [to_save_4,to_save_2,to_save,to_save_3] 
  #   {:ok, results, continuation} = Riak.find(bucket, {'data', -2, 10}, max_results: 3)
  #   assert results == [to_save_4,to_save_2,to_save]
  #   {:ok, results, _} = Riak.find(bucket, {'data', -2, 10}, continuation: continuation)
  #   assert results == [to_save_3]
  # end

end