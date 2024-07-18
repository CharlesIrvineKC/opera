defmodule Opera.Repo do
  use Ecto.Repo,
    otp_app: :opera,
    adapter: Ecto.Adapters.Postgres
end
