import Config

if System.get_env("PHX_SERVER") do
  config :controller, ControllerWeb.Endpoint, server: true
end

config :controller, ControllerWeb.Endpoint,
  http: [port: 4000]

if config_env() == :prod do
  config :controller, Controller.Repo,
    url: System.fetch_env!("DATABASE_URL"),
    pool_size: 10,
    socket_options: [],
    ssl: false

  config :controller, ControllerWeb.Endpoint,
    check_origin: false,
    url: [host: System.fetch_env!("DOMAIN"), port: 443, scheme: "http"],
    http: [
      :inet,
      ip: {0, 0, 0, 0}
    ],
    secret_key_base: System.fetch_env!("SECRET_KEY_BASE")
end
