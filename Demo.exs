defmodule Demo do

  def reverse() do
    receive do
      {pid, msg} ->
        IO.inspect pid
        result = msg |> String.reverse
        send pid, result
        reverse()
    end
  end
end
