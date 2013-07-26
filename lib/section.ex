defmodule Section do
  def add(name, section, distance, metric, time) do
    speed = :io_lib.format "~.1f", [distance/time]
    "your #{section} speed at the #{name} triathlon was #{speed} #{metric}/hour"
  end
end
