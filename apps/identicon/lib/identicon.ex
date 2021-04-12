defmodule Identicon do
  def from_string(str, size \\ 250) do
    hash = :crypto.hash(:md5, str) |> :binary.bin_to_list()
    generate_image(color(hash), coords(hash, size / 5), size)
  end

  defp color([r, g, b | _]), do: {r, g, b}

  defp coords(hash, u),
    do:
      hash
      |> Enum.chunk_every(3, 3, :discard)
      |> Enum.map(&mirror/1)
      |> List.flatten()
      |> Enum.with_index()
      |> Enum.filter(fn {v, _} = _x -> rem(v, 2) === 0 end)
      |> Enum.map(&square(&1, u))

  defp mirror([one, two | _] = row), do: row ++ [two, one]

  defp square({_, i}, u) do
    x = rem(i, 5) * u
    y = div(i, 5) * u
    top_left = {x, y}
    bottom_right = {x + u, y + u}
    {top_left, bottom_right}
  end

  defp generate_image(color, coords, size) do
    image = :egd.create(size, size)
    fill = :egd.color(color)

    Enum.each(coords, fn {{x1, y1}, {x2, y2}} ->
      start = {round(x1), round(y1)}
      stop = {round(x2), round(y2)}
      :egd.filledRectangle(image, start, stop, fill)
    end)

    :egd.render(image)
  end
end
