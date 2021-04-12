defmodule Identicon.MixProject do
  use Mix.Project

  def project do
    [
      app: :identicon,
      version: "0.1.0",
      elixir: "~> 1.11",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  defp deps do
    [{:egd, github: "erlang/egd"}]
  end

  def application do
    [extra_applications: [:logger, :crypto]]
  end
end
