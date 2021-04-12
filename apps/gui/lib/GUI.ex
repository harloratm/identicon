defmodule Identicon.GUI do
  @behaviour :wx_object
  @default_input_string "identicon"

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
    win = make_window("Identicon generator")
    state = %{widgets: make_widgets(win), input_string: @default_input_string}
    layout = arrange_widgets(state.widgets)

    :wxTextCtrl.connect(state.widgets.tc_input, :command_text_updated)
    :wxButton.connect(state.widgets.bt_save, :command_button_clicked)
    :wxButton.connect(state.widgets.bt_quit, :command_button_clicked)

    :wxWindow.setSizer(win, layout)
    :wxSizer.setSizeHints(layout, win)
    :wxFrame.show(win)
    {win, state}
  end

  def arrange_widgets(widgets) do
    sz_main = :wxBoxSizer.new(wxVERTICAL())
    sz_toolbar = :wxBoxSizer.new(wxHORIZONTAL())
    :wxBoxSizer.add(sz_toolbar, widgets.bt_save, proportion: 1, flag: wxEXPAND())
    :wxBoxSizer.add(sz_toolbar, widgets.bt_quit, proportion: 1)
    :wxBoxSizer.add(sz_main, widgets.tc_input, border: 10, flag: wxEXPAND() ||| wxALL())

    :wxBoxSizer.add(sz_main, sz_toolbar,
      proportion: 0,
      border: 10,
      flag: wxEXPAND() ||| wxLEFT() ||| wxRIGHT()
    )

    :wxBoxSizer.add(sz_main, widgets.sb_image,
      proportion: 1,
      border: 10,
      flag: wxALIGN_CENTER() ||| wxALL()
    )

    sz_main
  end

  def make_window(title), do: :wx.new() |> :wxFrame.new(-1, title)

  def make_widgets(win),
    do: %{
      tc_input: :wxTextCtrl.new(win, -1, value: @default_input_string),
      bt_save: :wxButton.new(win, -1, label: "Save as PNG file"),
      bt_quit: :wxButton.new(win, 5006),
      sb_image: :wxStaticBitmap.new(win, -1, generate_image_from(@default_input_string)),
      dg_file:
        :wxFileDialog.new(win,
          message: "Save PNG file",
          style: wxFD_SAVE() ||| wxFD_OVERWRITE_PROMPT()
        )
    }

  def handle_event(
        {:wx, _, clicked, _, {:wxCommand, :command_button_clicked, _, _, _}},
        %{widgets: %{bt_quit: clicked}} = state
      ),
      do: {:stop, :normal, state}

  def handle_event(
        {:wx, _, clicked, _, {:wxCommand, :command_button_clicked, _, _, _}},
        %{widgets: %{bt_save: clicked}} = state
      ) do
    if :wxFileDialog.showModal(state.widgets.dg_file) == wxID_OK() do
      save_to_file(:wxFileDialog.getPath(state.widgets.dg_file), state.input_string)
    end

    {:noreply, state}
  end

  def handle_event(
        {:wx, _, _, _, {:wxCommand, :command_text_updated, value, _, _}},
        %{widgets: %{sb_image: sb_image}} = state
      ) do
    :wxStaticBitmap.setBitmap(sb_image, generate_image_from(value))
    new_state = %{state | input_string: value}
    {:noreply, new_state}
  end

  def handle_event(event, state) do
    IO.puts("Got this event:\n")
    IO.inspect(event)
    {:noreply, state}
  end

  defp generate_image_from(input_string),
    do: save_to_file(:temp, input_string) |> :wxImage.new() |> :wxBitmap.new()

  defp save_to_file(:temp, input_string), do: save_to_file(temp_filename(), input_string)

  defp save_to_file(filename, input_string) do
    image = Identicon.from_string(input_string)
    File.write(filename, image)
    filename
  end

  defp temp_filename(), do: System.tmp_dir!() |> Path.join("identicon.png")
end
