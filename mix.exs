defmodule Identicon.MixProject do
  use Mix.Project

  @default_project [
    app: :identicon,
    escript: [main_module: Identicon.CLI],
    version: "0.1.0",
    elixir: "~> 1.11",
    start_permanent: false,
    deps: [{:egd, github: "erlang/egd"}]
  ]

  def project, do: Keyword.merge(@default_project, project(Mix.env()))

  def project(:gui), do: [app: :wxidenticon, escript: [main_module: Identicon.GUI]]
  def project(_), do: []

  def application do
    [extra_applications: [:logger, :crypto, :wx]]
  end
end
