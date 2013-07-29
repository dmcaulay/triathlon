
defmodule Riak do
  defrecord Bucket, pid: nil, name: nil

  def connect(host, port) do
    :riakc_pb_socket.start_link(host, port)
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

  def set(bucket, key, obj) do
    riak_obj = :riakc_obj.new bucket.name, key, obj
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
end
