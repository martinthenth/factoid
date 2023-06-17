defmodule Factoid.Repo do
  @moduledoc false

  use Ecto.Repo,
    otp_app: :factoid,
    adapter: Ecto.Adapters.Postgres
end
