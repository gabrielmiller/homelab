defmodule ControllerWeb.AdminLive do
  use ControllerWeb, :live_view

  alias Controller.Commands

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <h1>Admin</h1>
      <div>
        <h2>Chatterbox</h2>
        <div>
          Is the service running?
          <.async_result
            :let={result}
            assign={@chatterbox_alive}
          >
            <:loading>
              <div>Loading</div>
            </:loading>
            <:failed>
              <div>Error!</div>
            </:failed>
            {result}
          </.async_result>
        </div>
        <div class="flex flex-row gap-x-2">
          <button
            class="btn btn-primary"
            phx-click={JS.push("run-command", value: %{command: "execute_start_chatterbox"})}
            type="button"
          >
            Start
          </button>

          <button
            class="btn btn-primary"
            phx-click={JS.push("run-command", value: %{command: "execute_stop_chatterbox"})}
            type="button"
          >
            Stop
          </button>
        </div>
      </div>

      <div>
        <h2>Machine</h2>
        <div>
          Is the machine running?
          <.async_result
            :let={result}
            assign={@machine_alive}
          >
            <:loading>
              <div>Loading</div>
            </:loading>
            <:failed>
              <div>Error!</div>
            </:failed>
            {result}
          </.async_result>
        </div>
        <div class="flex flex-row gap-x-2">
          <button
            class="btn btn-primary"
            phx-click={JS.push("run-command", value: %{command: "execute_wake_machine"})}
            type="button"
          >
            Start
          </button>

          <button
            class="btn btn-primary"
            phx-click={JS.push("run-command", value: %{command: "execute_poweroff_machine"})}
            type="button"
          >
            Stop
          </button>
        </div>
      </div>
    </div>
    """
  end

  @impl true
  def mount(_params, _url, socket) do
    socket =
      socket
      |> build_chatterbox_alive_assign()
      |> build_machine_alive_assign()

    {:ok, socket}
  end

  @impl true
  def handle_event("run-command", %{"command" => command}, socket) do
    command_atom = String.to_existing_atom(command)

    result = apply(Commands, command_atom, [])

    socket =
      if result == :ok do
        put_flash(socket, :info, "Successfully ran command")
      else
        put_flash(socket, :error, "Encountered error when running command")
      end

    {:noreply, socket}
  end

  def build_chatterbox_alive_assign(socket) do
    assign_async(socket, :chatterbox_alive, fn ->
      result = :ok == Commands.execute_server_check(service: :chatterbox)
      {:ok, %{chatterbox_alive: result}}
    end)
  end

  def build_machine_alive_assign(socket) do
    assign_async(socket, :machine_alive, fn ->
      result = :ok == Commands.execute_server_check()
      {:ok, %{machine_alive: result}}
    end)
  end
end
