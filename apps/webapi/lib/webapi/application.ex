defmodule Webapi.Application do
  use Application
  require Logger

  @impl true
  def start(_type, _args) do
    children = [
      {Plug.Cowboy, scheme: cowboy_scheme(), plug: Webapi.Router, options: [port: cowboy_port()]}
    ]

    opts = [strategy: :one_for_one, name: Webapi.Supervisor]
    Logger.info("Starting server at #{cowboy_scheme()}://127.0.0.1:#{cowboy_port()} ...")
    Supervisor.start_link(children, opts)
  end

  defp cowboy_port, do: Application.get_env(:webapi, :cowboy_port, 8080)
  defp cowboy_scheme, do: Application.get_env(:webapi, :cowboy_scheme, :http)
end
