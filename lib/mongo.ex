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
      docs 
      |> to_tuples 
      |> mongo_insert(collection.name) 
      |> to_keywords
    end
  end
  defp mongo_insert(docs, name), do: :mongo.insert(name, docs)

  def find(collection, query // []) do
    exec collection, fn ->
      query 
      |> to_tuple 
      |> mongo_find(collection.name) 
      |> :mongo_cursor.rest 
      |> to_keywords
    end
  end
  defp mongo_find(q, name), do: :mongo.find(name, q)

  def delete(collection, query // []) do
    exec collection, fn ->
      query 
      |> to_tuple 
      |> mongo_delete(collection.name)
    end
  end
  defp mongo_delete(q, name), do: :mongo.delete(name, q)

  defp exec(collection, to_do) do
    :mongo.do :unsafe, :master, collection.pid, collection.db, to_do
  end

  defp to_keywords(l), do: Enum.map(l, to_keyword(&1))
  defp to_keyword(tuple), do: tuple |> tuple_to_list |> to_keyword([])
  defp to_keyword([], acc), do: acc
  defp to_keyword([k, v | tail], acc), do: to_keyword(tail, [{k, v} | acc])

  defp to_tuples(l), do: Enum.map(l, to_tuple(&1))
  defp to_tuple(t) when is_tuple(t), do: t
  defp to_tuple(l) when is_list(l) do 
    l |> Enum.map(tuple_to_list(&1)) |> List.flatten |> list_to_tuple
  end
end
