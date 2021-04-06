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

    # TODO Implement these
    :wxButton.disable(state.widgets.bt_save)
    :wxButton.disable(state.widgets.bt_quit)

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
      bt_save: :wxButton.new(win, -1, label: "Save image"),
      bt_quit: :wxButton.new(win, -1, label: "Quit")
    }

    :wxButton.connect(widgets.bt_update, :command_button_clicked)

    Map.put(
      widgets,
      :sb_image,
      :wxStaticBitmap.new(win, -1, generate_identicon(widgets.tc_input))
    )
  end

  def handle_event(
        {:wx, _, _, _, {:wxCommand, :command_button_clicked, _, _, _}},
        %{widgets: %{tc_input: tc_input, sb_image: sb_image}} = state
      ) do
    :wxStaticBitmap.setBitmap(sb_image, generate_identicon(tc_input))
    {:noreply, state}
  end

  def handle_event(_, state), do: {:noreply, state}

  defp generate_identicon(textctrl) do
    img_data = :wxTextCtrl.getValue(textctrl) |> Identicon.from_string()
    tmp_filename = System.tmp_dir!() |> Path.join("identicon.png")
    File.write(tmp_filename, img_data)
    :wxImage.new(tmp_filename) |> :wxBitmap.new()
  end
end
