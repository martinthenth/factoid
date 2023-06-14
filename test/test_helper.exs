Factoid.Repo.start_link()
ExUnit.start()

defmodule Factoid.Schemas.User do
  use Ecto.Schema

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  @timestamps_opts [type: :utc_datetime_usec, inserted_at: :created_at]

  schema "users" do
    field(:name, :string)
    field(:age, :integer)

    timestamps()
  end
end

defmodule Factoid.Schemas.Employee do
  use Ecto.Schema

  alias Factoid.Schemas.User

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  @timestamps_opts [type: :utc_datetime_usec, inserted_at: :created_at]

  schema "employees" do
    belongs_to(:user, User)

    field(:role, :string)

    timestamps()
  end
end
