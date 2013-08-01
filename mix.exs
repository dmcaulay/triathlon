defmodule Triathlon.Mixfile do
  use Mix.Project

  def project do
    [ app: :triathlon,
      version: "0.0.1",
      deps: deps ]
  end

  # Configuration for the OTP application
  def application do
    []
  end

  # Returns the list of dependencies in the format:
  # { :foobar, "0.1", git: "https://github.com/elixir-lang/foobar.git" }
  defp deps do
    [ 
      { :'riakc', "1.4.0", git: "https://github.com/basho/riak-erlang-client.git" },
      { :'mongodb', "v0.3.2", git: "https://github.com/dmcaulay/mongodb-erlang.git", branch: "refactor", tag: "v0.3.2" }
    ]
  end
end
