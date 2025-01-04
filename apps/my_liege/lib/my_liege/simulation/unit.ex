defmodule MyLiege.Simulation.Unit do
  def process_input(input, remaining, %{needed: needed, output: output}) when is_number(input) do
    (input + remaining)
    |> work_done(needed)
    |> output(output)
  end

  def work_done(new_work, needed) do
    {new_work, div(new_work, needed), rem(new_work, needed)}
  end

  def output({new_work, done, _remaining}, _output) when done < 0 do
    {new_work, 0}
  end

  def output({_new_work, done, remaining}, output) when done >= 0 do
    {remaining, done * output}
  end
end
