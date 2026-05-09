defmodule Controller.Repo do
  use Ecto.Repo,
    otp_app: :controller,
    adapter: Ecto.Adapters.Postgres
end
