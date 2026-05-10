defmodule ControllerWeb.HomeLive do
  use ControllerWeb, :live_view

  def render(assigns) do
    ~H"""
    <div>
      <h1>Home</h1>
      <p>Welcome home!</p>
    </div>
    """
  end
end
