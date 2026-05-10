defmodule ControllerWeb.AdminLive do
  use ControllerWeb, :live_view

  def render(assigns) do
    ~H"""
    <div>
      <h1>Admin</h1>
      <p>Welcome to admin!</p>
    </div>
    """
  end
end
