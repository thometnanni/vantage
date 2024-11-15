defmodule Vantage.Repo do
  use Ecto.Repo,
    otp_app: :vantage,
    adapter: Ecto.Adapters.Postgres
end
