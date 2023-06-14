defmodule Factoid.Repo do
  use Ecto.Repo,
    otp_app: :factoid,
    adapter: Ecto.Adapters.Postgres
end
