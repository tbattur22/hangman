defmodule Procs do
  def hello(count) do
    receive do
      msg ->
        IO.puts "#{count}: Hello #{inspect msg}"
    end
    hello(count + 1)
  end
end
