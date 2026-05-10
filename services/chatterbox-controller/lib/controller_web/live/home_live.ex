defmodule ControllerWeb.HomeLive do
  use ControllerWeb, :live_view

  alias Controller.Commands
  alias Phoenix.LiveView.AsyncResult

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <h1>Home</h1>
    </div>
    """
  end

  @impl true
  def mount(_params, _url, socket) do
    socket =
      socket
      |> assign(page_title: "Loading")
      |> start_async(:aliveness_check, fn ->
        Commands.execute_server_check(service: :chatterbox)
      end)

    {:ok, socket}
  end

  @impl true
  def handle_async(:aliveness_check, {:ok, :ok}, socket) do
    {:noreply, push_navigate(socket, to: ~p"/chatterbox")}
  end

  def handle_async(:aliveness_check, {:ok, _}, socket), do: handle_not_alive(socket)
  def handle_async(:aliveness_check, _, socket), do: handle_not_alive(socket)

  def handle_not_alive(socket) do
    socket =
      socket
      |> put_flash(
        :info,
        "The service is not running or an error occurred checking its aliveness."
      )
      |> push_navigate(to: ~p"/admin")

    {:noreply,
     assign(socket, :org, AsyncResult.failed(:aliveness_check, {:exit, "aliveness failure"}))}
  end
end
