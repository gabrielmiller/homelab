defmodule Controller.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    write_private_key()

    children = [
      ControllerWeb.Telemetry,
      Controller.Repo,
      {Phoenix.PubSub, name: Controller.PubSub},
      {Oban, Application.fetch_env!(:controller, Oban)},
      # Start a worker by calling: Controller.Worker.start_link(arg)
      # {Controller.Worker, arg},
      # Start to serve requests, typically the last entry
      ControllerWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Controller.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    ControllerWeb.Endpoint.config_change(changed, removed)
    :ok
  end

  defp write_private_key() do
    contents = Application.fetch_env!(:controller, :ssh_private_key)
    path = Application.fetch_env!(:controller, :ssh_private_key_path)

    File.write!(path, contents)
    File.chmod!(path, 0o600)
  end
end
