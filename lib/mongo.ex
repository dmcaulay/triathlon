defmodule Mongo do
  defrecord Collection, pid: nil, db: nil, name: nil

  def init do
    :application.start :bson
    :application.start :mongodb
  end

  def shutdown do
    :application.stop :bson
    :application.stop :mongodb
  end

  def connect(host, port, options // []) do
    :mongo_connection.start_link({host, port}, options)
  end

  def get_collection(host, port, db, name, options // []) do
    res = connect host, port, options
    case res do
      {:ok, pid} -> get_collection pid, db, name
      _ -> res
    end
  end

  def get_collection(pid, db, name) do 
    {:ok, Collection.new pid: pid, db: db, name: name}
  end

  def insert(collection, docs) do
    exec collection, fn ->
      :mongo.insert(collection.name, docs)
    end
  end

  def find(collection, query) do
    exec collection, fn ->
      cursor = :mongo.find(collection.name, query)
      :mongo_cursor.rest cursor
    end
  end

  def delete(collection, query // {}) do
    exec collection, fn ->
      :mongo.delete(collection.name, query)
    end
  end

  defp exec(collection, to_do) do
    :mongo.do :unsafe, :master, collection.pid, collection.db, to_do
  end

end
