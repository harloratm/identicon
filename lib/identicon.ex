defmodule Identicon do
  def from_string(str) do
    str
    |> hash
    |> pick_color
    |> build_grid
    |> filter_odds
    |> build_pixels
    |> draw_image
    |> save(str)
  end

  def hash(str) do
    %Identicon.Image{hex: :crypto.hash(:md5, str) |> :binary.bin_to_list()}
  end

  def pick_color(%Identicon.Image{hex: [r, g, b | _]} = image) do
    %Identicon.Image{image | color: {r, g, b}}
  end

  def build_grid(%Identicon.Image{hex: hex} = image) do
    grid =
      hex
      |> Enum.chunk_every(3, 3, :discard)
      |> Enum.map(&mirror/1)
      |> List.flatten()
      |> Enum.with_index()

    %Identicon.Image{image | grid: grid}
  end

  def mirror([one, two | _] = row) do
    row ++ [two, one]
  end

  def filter_odds(%Identicon.Image{grid: grid} = image) do
    grid = Enum.filter(grid, fn {v, _} = _x -> rem(v, 2) === 0 end)

    %Identicon.Image{image | grid: grid}
  end

  def build_pixels(%Identicon.Image{grid: grid} = image) do
    pixel_map =
      Enum.map(grid, fn {_, i} ->
        x = rem(i, 5) * 50
        y = div(i, 5) * 50
        top_left = {x, y}
        bottom_right = {x + 50, y + 50}
        {top_left, bottom_right}
      end)

    %Identicon.Image{image | pixel_map: pixel_map}
  end

  def draw_image(%Identicon.Image{color: color, pixel_map: pixel_map}) do
    image = :egd.create(250, 250)
    fill = :egd.color(color)

    Enum.each(pixel_map, fn {start, stop} ->
      :egd.filledRectangle(image, start, stop, fill)
    end)

    :egd.render(image)
  end

  def save(image, filename) do
    File.write("#{filename}.png", image)
  end
end
