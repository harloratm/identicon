defmodule Identicon.Umbrella.MixProject do
  use Mix.Project

  def project do
    [
      apps_path: "apps",
      version: "0.1.0",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      releases: [
        identiconweb: [
          version: "0.0.1",
          applications: [webapi: :permanent]
        ]
      ]
    ]
  end

  defp deps do
    []
  end
end
