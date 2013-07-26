defmodule CLI do

  @moduledoc """
  Handle the command line parsing and the dispatch to
  the various functions that end up generating a 
  table of the last _n_ issues in a github project
  """

  def run(argv) do
    argv |> parse_args |> process
  end

  @doc """
  `argv` can be -h or --help, which returns :help.

  Otherwise it is the triathlon section, section distiance, metric and time.

  Return a tuple of `{ user, project, count }`, or `:help` if help was given.
  """
  def parse_args(argv) do
    parse = OptionParser.parse(argv, switches: [ help: :boolean ], aliases: [ h: :help ])
    case  parse  do
    { _, [ race_name, section, distance, metric, time ] } -> 
      { 
        race_name, 
        binary_to_atom(section), 
        binary_to_integer(distance),
        binary_to_atom(metric), 
        parse_time(time) 
      }
    { [ help: true ], _ } -> :help
    _ -> :help
    end
  end

  def parse_time(time) do
    time |> split |> to_int |> to_hours
  end

  def split(time) do
    String.split(time, ":")
  end

  def to_int(l) do
    Enum.map(l, binary_to_integer(&1))
  end

  def to_hours(l) do
    case l do
    [ seconds ] -> seconds/60/60
    [ minutes, seconds ] -> minutes/60 + seconds/60/60
    [ hours, minutes, seconds ] -> hours + minutes/60 + seconds/60/60
    end
  end

  def process(:help) do
    IO.puts """
    usage: triathlon <race_name> <section> <distance> <metric> <time> 
    """
    System.halt(0)
  end

  def process({race_name, section, distance, metric, time}) do 
    IO.puts Section.add(race_name, section, distance, metric, time)
  end
end
