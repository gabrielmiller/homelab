defmodule Controller.Commands do
  @moduledoc false

  @application :controller

  defp command_network_check() do
    "nmcli -t device"
  end

  defp command_server_check(port) do
    "nc -v -z -w 1 #{hostname()} #{port}"
  end

  defp command_wake_machine(wol_alias) do
    "#{wol_alias} #{Application.fetch_env!(@application, :chatterbox_system_mac_address)}"
  end

  defp command_start_chatterbox(),
    do:
      proxy_through_ssh(
        "cd #{chatterbox_remote_path()} && docker compose -f docker-compose-rocm.yml up -d"
      )

  defp command_stop_chatterbox(),
    do: proxy_through_ssh("cd #{chatterbox_remote_path()} && docker compose stop")

  defp command_poweroff_machine(),
    do: proxy_through_ssh("sudo poweroff", flags: ["-t"])

  def execute_network_check() do
    connection_interface = Application.fetch_env!(@application, :connection_interface)
    connection_type = Application.fetch_env!(@application, :connection_type)

    parse_stdout = fn stdout ->
      stdout
      |> String.split("\n")
      |> Enum.any?(&(&1 =~ "#{connection_interface}:#{connection_type}:connected:"))
      |> then(fn match ->
        if match,
          do: :ok,
          else: :error
      end)
    end

    with {:ok, [stdout: [stdout]]} <- command_network_check() |> :exec.run([:sync, :stdout]),
         :ok <- parse_stdout.(stdout) do
      :ok
    else
      _e -> {:error, :network_offline}
    end
  end

  def execute_server_check(port \\ 22) do
    with {:ok, _} <- command_server_check(port) |> :exec.run([:sync]) do
      :ok
    else
      _e -> {:error, :server_offline}
    end
  end

  def execute_wake_machine(wol_alias \\ "wol") do
    parse_stdout = fn stdout ->
      stdout
      |> String.split("\n")
      |> Enum.any?(&(&1 =~ "Magic packets: <sent=1>"))
      |> then(fn match ->
        if match,
          do: :ok,
          else: :error
      end)
    end

    with {:ok, [stdout: [stdout]]} <-
           command_wake_machine(wol_alias) |> :exec.run([:sync, :stdout, :stderr]),
         :ok <- parse_stdout.(stdout) do
      :ok
    else
      _e -> {:error, :failed_to_send_wake_msg}
    end
  end

  def execute_start_chatterbox() do
    with {:ok, _} <- command_start_chatterbox() |> :exec.run([:sync, :stdout, :stderr]) do
      :ok
    else
      _e -> {:error, :failed_to_send_start_msg}
    end
  end

  def execute_stop_chatterbox() do
    with {:ok, _} <- command_stop_chatterbox() |> :exec.run([:sync, :stdout, :stderr]) do
      :ok
    else
      _e -> {:error, :failed_to_send_stop_msg}
    end
  end

  def execute_poweroff_machine() do
    with {:ok, _} <- command_poweroff_machine() |> :exec.run([:sync, :stdout, :stderr]) do
      :ok
    else
      _e -> {:error, :failed_to_send_poweroff_msg}
    end
  end

  defp proxy_through_ssh(command, opts \\ []) do
    flags =
      opts
      |> Keyword.get(:flags, [])
      |> Enum.join(" ")

    private_key_path = Application.fetch_env!(@application, :ssh_private_key_path)
    remote_user = Application.fetch_env!(@application, :ssh_remote_user)

    "ssh -i #{private_key_path} #{remote_user}@#{hostname()} #{flags} \"#{command}\""
  end

  defp chatterbox_remote_path(),
    do: Application.fetch_env!(@application, :chatterbox_remote_path)

  defp hostname(),
    do: Application.fetch_env!(@application, :ssh_hostname)
end
