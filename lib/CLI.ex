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

  defp clean({switches, args, _} = parsed) do
    cond do
      Keyword.get(switches, :help) -> {:ok, :usage}
      args == [] -> {:error, "An input string is needed."}
      length(args) != 1 -> {:error, "Only one input string is allowed."}
      true -> {:ok, parsed}
    end
  end

  defp run({:error, message}) do
    IO.puts(:stderr, message)
    System.halt(1)
  end

  defp run({:ok, :usage}), do: usage()

  defp run({:ok, {_, input, invalid}}) do
    warn_invalid(invalid)
    image = Identicon.from_string(input)
    File.write("#{input}.png", image)
    IO.puts("Done. #{input}.png saved.")
  end

  defp warn_invalid(args),
    do: Enum.map(args, fn {o, _} -> IO.puts(:stderr, "WARNING: option #{o} is unknown.") end)

  defp usage,
    do:
      IO.puts("""
      Usage: identicon [options] WORD
      Options:
        -o FILE, --output FILE      The generated image filename.
        -h, --help                  Print this message and exit.
      """)
end
