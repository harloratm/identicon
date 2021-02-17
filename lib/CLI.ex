defmodule Identicon.CLI do
  def main(args) do
    args |> parse |> clean |> run
  end

  defp parse(args),
    do:
      OptionParser.parse(args,
        strict: [help: :boolean, output: :string, size: :integer],
        aliases: [h: :help, o: :output, s: :size]
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

  defp run({:ok, {opts, [input], invalid}}) do
    warn_invalid(invalid)
    save(input, opts)
    IO.puts("Done.")
  end

  defp save(input, opts) do
    image = Identicon.from_string(input, size(opts))
    filename = outfile(opts, input)
    File.write(filename, image)
  end

  defp outfile(opts, input) do
    basename = Keyword.get(opts, :output, "#{input}")
    "#{basename}.png"
  end

  defp size(opts), do: Keyword.get(opts, :size, 250)

  defp warn_invalid(args),
    do:
      Enum.map(
        args,
        fn arg ->
          o = Enum.join(Tuple.to_list(arg), " ")
          IO.puts(:stderr, "WARNING: option #{o} is wrong or unknown.")
        end
      )

  defp usage,
    do:
      IO.puts("""
      Usage: identicon [options] WORD
      Options:
        -o FILE, --output FILE      The generated image filename (the .png extension is
                                    automatically appended).
        -s SIZE, --size SIZE        The size of the square image (defaults to 250).
        -h, --help                  Print this message and exit.
      """)
end
