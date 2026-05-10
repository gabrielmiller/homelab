import Config

if System.get_env("PHX_SERVER") do
  config :controller, ControllerWeb.Endpoint, server: true
end

config :controller, ControllerWeb.Endpoint,
  http: [port: String.to_integer(System.get_env("PORT", "4000"))]

if config_env() == :prod do
  database_url =
    System.get_env("DATABASE_URL") ||
      raise """
      environment variable DATABASE_URL is missing.
      For example: ecto://USER:PASS@HOST/DATABASE
      """

  config :controller, Controller.Repo,
    url: database_url,
    pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10"),
    socket_options: [],
    ssl: false

  secret_key_base =
    System.get_env("SECRET_KEY_BASE") ||
      raise """
      environment variable SECRET_KEY_BASE is missing.
      You can generate one by calling: mix phx.gen.secret
      """

  host = System.get_env("PHX_HOST") || "localhost"

  config :controller, :dns_cluster_query, System.get_env("DNS_CLUSTER_QUERY")

  config :controller, ControllerWeb.Endpoint,
    check_origin: false,
    url: [host: host, port: 443, scheme: "http"],
    http: [
      :inet,
      ip: {0, 0, 0, 0}
    ],
    secret_key_base: secret_key_base
end
