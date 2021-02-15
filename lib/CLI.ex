defmodule Identicon.CLI do
  def main(args) do
    args |> parse |> clean |> run
  end

  defp parse(args),
    do:
      OptionParser.parse(args,
        strict: [help: :boolean, output: :string],
        aliases: [h: :help, o: :output]
      )

  defp clean(parsed) do
    case(parsed) do
      {[help: true], _, _} -> {:ok, :usage}
      {[help: true, output: _], _, _} -> {:ok, :usage}
      {[output: _, help: true], _, _} -> {:ok, :usage}
      {_, [], _} -> {:error, "An input string is needed."}
      {_, args, _} when length(args) != 1 -> {:error, "Only one input string is allowed."}
      parsed -> {:ok, parsed}
    end
  end

  defp run({:error, message}) do
    IO.puts(:stderr, message)
    System.halt(1)
  end

  defp run({:ok, :usage}), do: usage()

  defp run({:ok, {_, input, invalid}}) do
    Enum.map(invalid, fn {o, _} -> IO.puts(:stderr, "WARNING: option #{o} is unknown.") end)
    File.write("#{input}.png", Identicon.from_string(input))
    IO.puts("Done. #{input}.png saved.")
  end

  defp(usage()) do
    s = """
    Usage: identicon [options] WORD
    Options:
      -o FILE, --output FILE      The generated image filename.
      -h, --help                  Print this message and exit.
    """

    IO.puts(s)
  end
end
