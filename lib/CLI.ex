defmodule Identicon.CLI do
  def main(args) do
    {_, [str | _], _} = OptionParser.parse(args, strict: [])

    File.write(Identicon.filename(str), Identicon.from_string(str))
  end
end
