defmodule MyLiege.Simulation.Unit do
  def process_input(input, remaining, %{needed: needed, output: output})
      when is_integer(input) and is_integer(remaining) do
    (input + remaining)
    |> work_done(needed)
    |> output(output)
  end

  defp work_done(new_work, needed) do
    {new_work, div(new_work, needed), rem(new_work, needed)}
  end

  defp output({new_work, done, _remaining}, _output) when done < 0 do
    {new_work, 0}
  end

  defp output({_new_work, done, remaining}, output) when done >= 0 do
    {remaining, done * output}
  end
end
