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
      tuples = Enum.map docs, to_tuple(&1)
      :mongo.insert(collection.name, tuples)
    end
  end
  defp to_tuple(list) do 
    list |> Enum.map(tuple_to_list(&1)) |> List.flatten |> list_to_tuple
  end

  def find(collection, query // []) do
    exec collection, fn ->
      cursor = :mongo.find(collection.name, to_tuple(query))
      results = :mongo_cursor.rest cursor
      Enum.map results, to_keyword(&1) 
    end
  end

  defp to_keyword(tuple), do: tuple |> tuple_to_list |> to_keyword([])
  defp to_keyword([], acc), do: acc
  defp to_keyword([k, v | tail], acc), do: to_keyword(tail, [{k, v} | acc])

  def delete(collection, query // []) do
    exec collection, fn ->
      :mongo.delete collection.name, to_tuple(query)
    end
  end

  defp exec(collection, to_do) do
    :mongo.do :unsafe, :master, collection.pid, collection.db, to_do
  end

end
