defmodule Identicon.GUI do
  @behaviour :wx_object

  use Bitwise, only_operators: true

  def start_link() do
    :wx_object.start_link(__MODULE__, [], [])
  end

  def init(_args \\ []) do
    wx = :wx.new()
    win = :wxFrame.new(wx, -1, "Identicon generator")

    input_text = :wxTextCtrl.new(win, -1, value: "identicon", size: {500, -1})
    generate_button = :wxButton.new(win, -1, label: "Make identicon")
    image = :wxImage.new("lenin.png", [])
    bitmap = :wxBitmap.new(:wxImage.scale(image, 250, 250, quality: 0))
    static_bitmap = :wxStaticBitmap.new(win, -1, bitmap)

    sizer_main = :wxBoxSizer.new(8)
    sizer_top = :wxBoxSizer.new(4)

    :wxSizer.add(sizer_top, input_text, flag: 64 ||| 16 ||| 128 ||| 32, border: 10, proportion: 1)
    :wxSizer.add(sizer_top, generate_button, flag: 64 ||| 32 ||| 128, border: 10)
    :wxSizer.add(sizer_main, sizer_top)

    :wxSizer.add(sizer_main, static_bitmap,
      flag: 64 ||| 16 ||| 128 ||| 32,
      border: 10,
      proportion: 1
    )

    :wxButton.connect(generate_button, :command_button_clicked)

    :wxWindow.setSizer(win, sizer_main)
    :wxSizer.setSizeHints(sizer_main, win)
    :wxFrame.show(win)

    state = %{input_control: input_text, image_control: static_bitmap}
    {win, state}
  end

  def handle_event(
        {:wx, _, _, _, {:wxCommand, :command_button_clicked, _, _, _}},
        %{input_control: input_text, image_control: static_bitmap} = state
      ) do
    img_data = input_text |> :wxTextCtrl.getValue() |> Identicon.from_string()
    tmp_dir = System.tmp_dir!()
    tmp_filename = Path.join(tmp_dir, "identicon.png")
    File.write(tmp_filename, img_data)
    image = :wxImage.new(tmp_filename)
    bitmap = :wxBitmap.new(image)
    :wxStaticBitmap.setBitmap(static_bitmap, bitmap)

    {:noreply, state}
  end

  def handle_event(event, state) do
    IO.inspect(event)
    {:noreply, state}
  end

  def main(_) do
    {:wx_ref, _, _, pid} = start_link()
    ref = Process.monitor(pid)

    receive do
      {:DOWN, ^ref, _, _, _} -> :ok
    end
  end
end
