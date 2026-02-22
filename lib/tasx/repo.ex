defmodule TasxCore.Repo do
  use Ecto.Repo,
    otp_app: :tasx,
    adapter: Ecto.Adapters.Postgres
end
