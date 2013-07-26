defmodule Section do
  def add(name, section, distance, metric, time) do
    speed = :io_lib.format "~.1f", [distance/time]
    "your #{section} speed at the #{name} triathlon is #{speed} #{metric}/hour"
  end
end
