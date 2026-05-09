defmodule ControllerWeb.PageController do
  use ControllerWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
