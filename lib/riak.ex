
defmodule Riak do
  defrecord Bucket, pid: nil, name: nil, indexes: nil
  defrecord Index, type: nil, field: nil

  def connect(host, port) do
    :riakc_pb_socket.start_link host, port
  end

  def create_bucket(host, port, name) do
    res = connect host, port
    case res do
      {:ok, pid} -> create_bucket pid, name
      _ -> res
    end
  end

  def create_bucket(pid, name) do
    {:ok, Bucket.new pid: pid, name: name}
  end

  def set_indexes(bucket, indexes) do
    bucket.indexes indexes
  end

  def set(bucket, key, obj) do
    riak_obj = :riakc_obj.new bucket.name, key, obj
    riak_obj = add_indexes bucket, obj, riak_obj
    :riakc_pb_socket.put bucket.pid, riak_obj
  end

  def get(bucket, key, decode // true) do
    res = :riakc_pb_socket.get bucket.pid, bucket.name, key
    case res do
      {:ok, obj} -> 
        value = :riakc_obj.get_value obj
        if decode, do: binary_to_term(value), else: value
      _ -> res
    end
  end

  def delete(bucket, key) do
    :riakc_pb_socket.delete bucket.pid, bucket.name, key
  end

  def find(bucket, {field, value}) do
    res = :riakc_pb_socket.get_index(bucket.pid, bucket.name, {:binary_index, field}, value)
    case res do
      {:ok, {_,keys,_,_}} -> 
        Enum.map keys, get(bucket, &1)
      _ -> res
    end
  end

  def find(bucket, {field, start, stop}) do
    res = :riakc_pb_socket.get_index(bucket.pid, bucket.name, {:integer_index, field}, start, stop)
    case res do
      {:ok, keys} -> 
        Enum.map keys, get(bucket, &1)
      _ -> res
    end
  end

  defp add_indexes(Bucket[indexes: nil], _, riak_obj), do: riak_obj

  defp add_indexes(bucket, obj, riak_obj) do
    meta = :riakc_obj.get_update_metadata riak_obj
    to_index = Enum.map bucket.indexes, fn(i = {type, field}) ->
      {val, _} = Code.eval_string "obj.#{field}", [obj: obj]
      {i, [val]}
    end
    indexed = :riakc_obj.set_secondary_index meta, to_index
    :riakc_obj.update_metadata riak_obj, indexed
  end

end
