defmodule Identicon.MixProject do
  use Mix.Project

  def project do
    Keyword.merge(
      [
        app: :identicon,
        escript: [main_module: Identicon.CLI],
        version: "0.1.0",
        elixir: "~> 1.11",
        start_permanent: Mix.env() == :prod,
        deps: deps()
      ],
      env_conf(Mix.env())
    )
  end

  def application do
    [
      extra_applications: [:logger, :crypto, :wx]
    ]
  end

  defp deps do
    [
      {:egd, github: "erlang/egd"}
    ]
  end

  defp env_conf(:gui), do: [app: :wxidenticon, escript: [main_module: Identicon.GUI]]
  defp env_conf(_), do: []
end
