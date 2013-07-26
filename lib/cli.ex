defmodule CLI do

  @moduledoc """
  Handle the command line parsing and the dispatch to
  the various functions that end up generating a 
  table of the last _n_ issues in a github project
  """

  def run(argv) do
    argv
      |> parse_args
      |> process
  end

  @doc """
  `argv` can be -h or --help, which returns :help.

  Otherwise it is the triathlon section, section distiance, metric and time.

  Return a tuple of `{ user, project, count }`, or `:help` if help was given.
  """
  def parse_args(argv) do
    parse = OptionParser.parse(argv, switches: [ help: :boolean],
                                     aliases:  [ h:    :help   ])
    case  parse  do

    { [ help: true ], _ }           -> :help
    { _, [ name, section, distance, metric, time ] } -> { name, section, binary_to_integer(distance), metric, parse_time(time) }
    _                               -> :help
    end
  end

  def parse_time(time) do
    String.split(time, ":") |> to_int |> to_seconds |> sum
  end

  def to_int(l) do
    Enum.map(l, binary_to_integer(&1))
  end

  def to_seconds(l) do
    Enum.reduce l, [], fn(x, acc) ->
      acc = Enum.map(acc, &1 * 60)
      [ x | acc ]
    end
  end

  def sum(l) do
    Enum.reduce l, 0, &1 + &2
  end

  def process(:help) do
    IO.puts """
    usage: triathlon <name> <section> <distance> <metric> <time> 
    """
    System.halt(0)
  end

  def process({name, section, distance, metric, time}) do 
    Triathlon.add(name, section, distance, time)
  end
end
