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
    win = make_window("Identicon generator")
    state = Map.put(%{}, :widgets, make_widgets(win))
    layout = arrange_widgets(state.widgets)
    :wxWindow.setSizer(win, layout)
    :wxSizer.setSizeHints(layout, win)
    :wxFrame.show(win)
    {win, state}
  end

  def arrange_widgets(widgets) do
    sz_main = :wxBoxSizer.new(wxVERTICAL())
    sz_toolbar = :wxBoxSizer.new(wxHORIZONTAL())
    :wxBoxSizer.add(sz_toolbar, widgets.bt_update, proportion: 1, flag: wxEXPAND())
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

  def make_widgets(win) do
    widgets = %{
      tc_input: :wxTextCtrl.new(win, -1, value: "identicon"),
      bt_update: :wxButton.new(win, -1, label: "Update image"),
      bt_save: :wxButton.new(win, 5003),
      bt_quit: :wxButton.new(win, 5006),
      dg_file:
        :wxFileDialog.new(win,
          message: "Save PNG file",
          style: wxFD_SAVE() ||| wxFD_OVERWRITE_PROMPT()
        )
    }

    :wxButton.connect(widgets.bt_update, :command_button_clicked)
    :wxButton.connect(widgets.bt_save, :command_button_clicked)
    :wxButton.connect(widgets.bt_quit, :command_button_clicked)

    Map.put(
      widgets,
      :sb_image,
      :wxStaticBitmap.new(win, -1, generate_identicon(widgets.tc_input))
    )
  end

  def handle_event(
        {:wx, _, clicked, _, {:wxCommand, :command_button_clicked, _, _, _}},
        state
      ) do
    cond do
      clicked == state.widgets.bt_quit -> quit(state)
      clicked == state.widgets.bt_save -> save(state)
      clicked == state.widgets.bt_update -> update(state)
    end
  end

  def handle_event(event, state) do
    IO.puts("Got this event:\n")
    IO.inspect(event)
    {:noreply, state}
  end

  defp quit(state) do
    {:stop, :normal, state}
  end

  defp save(state) do
    if :wxFileDialog.showModal(state.widgets.dg_file) == wxID_OK() do
      filename = :wxFileDialog.getPath(state.widgets.dg_file)
      image = :wxTextCtrl.getValue(state.widgets.tc_input) |> Identicon.from_string()
      File.write(filename, image)
    end

    {:noreply, state}
  end

  defp update(%{widgets: %{sb_image: sb_image, tc_input: tc_input}} = state) do
    :wxStaticBitmap.setBitmap(sb_image, generate_identicon(tc_input))
    {:noreply, state}
  end

  defp generate_identicon(textctrl) do
    img_data = :wxTextCtrl.getValue(textctrl) |> Identicon.from_string()
    tmp_filename = System.tmp_dir!() |> Path.join("identicon.png")
    File.write(tmp_filename, img_data)
    :wxImage.new(tmp_filename) |> :wxBitmap.new()
  end
end
