defmodule Identicon.GUI do
  @behaviour :wx_object

  import WxConstants
  use Bitwise, only_operators: true

  def main(_) do
    {:wx_ref, _, _, pid} = start_link()
    ref = Process.monitor(pid)

    receive do
      {:DOWN, ^ref, _, _, _} -> :ok
    end
  end

  def start_link(), do: :wx_object.start_link(__MODULE__, [], [])

  def init(_) do
    wx = :wx.new()
    win = :wxFrame.new(wx, -1, "Identicon generator")

    input_text = :wxTextCtrl.new(win, -1, value: "identicon", size: {200, -1})
    generate_button = :wxButton.new(win, -1, label: "generate identicon")
    static_bitmap = :wxStaticBitmap.new(win, -1, bitmap_from_text_ctrl(input_text))

    sizer_main = :wxBoxSizer.new(8)
    sizer_top = :wxBoxSizer.new(4)

    :wxSizer.add(sizer_top, input_text,
      border: 10,
      flag: wxTOP() ||| wxRIGHT() ||| wxBOTTOM() ||| wxLEFT()
    )

    :wxSizer.add(sizer_top, generate_button,
      border: 10,
      flag: wxTOP() ||| wxRIGHT() ||| wxBOTTOM()
    )

    :wxSizer.add(sizer_main, sizer_top)

    :wxSizer.add(sizer_main, static_bitmap,
      border: 10,
      flag: wxRIGHT() ||| wxBOTTOM() ||| wxLEFT(),
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
    :wxStaticBitmap.setBitmap(static_bitmap, bitmap_from_text_ctrl(input_text))
    {:noreply, state}
  end

  def handle_event(_, state), do: {:noreply, state}

  defp bitmap_from_text_ctrl(text_ctrl) do
    img_data = :wxTextCtrl.getValue(text_ctrl) |> Identicon.from_string()
    tmp_filename = System.tmp_dir!() |> Path.join("identicon.png")
    File.write(tmp_filename, img_data)
    :wxImage.new(tmp_filename) |> :wxBitmap.new()
  end
end
