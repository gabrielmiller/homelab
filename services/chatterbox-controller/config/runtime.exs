import Config

if System.get_env("PHX_SERVER") do
  config :controller, ControllerWeb.Endpoint, server: true
end

config :controller, ControllerWeb.Endpoint, http: [port: 4000]

config :controller,
  connection_interface: System.fetch_env!("CONNECTION_INTERFACE"),
  connection_type: System.fetch_env!("CONNECTION_TYPE"),
  chatterbox_port: String.to_integer(System.fetch_env!("CHATTERBOX_PORT")),
  chatterbox_remote_path: System.fetch_env!("CHATTERBOX_REMOTE_PATH"),
  chatterbox_system_mac_address: System.fetch_env!("CHATTERBOX_SYSTEM_MAC_ADDRESS"),
  ssh_hostname: System.fetch_env!("SSH_HOSTNAME"),
  ssh_port: String.to_integer(System.fetch_env!("SSH_PORT")),
  ssh_private_key: System.fetch_env!("SSH_PRIVATE_KEY"),
  ssh_private_key_path: "/tmp/ssh_private_key",
  ssh_remote_user: System.fetch_env!("SSH_REMOTE_USER"),
  wol_alias: System.fetch_env!("WOL_ALIAS")

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
