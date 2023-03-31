Fact.Repo.start_link()
ExUnit.start()

defmodule Fact.Schemas.User do
  use Ecto.Schema

  alias Ecto.UUID

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  @timestamps_opts [type: :utc_datetime_usec, inserted_at: :created_at]

  schema "users" do
    field(:name, :string)
    field(:age, :integer)

    timestamps()
  end
end

defmodule Fact.Schemas.Employee do
  use Ecto.Schema

  alias Ecto.UUID

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  @timestamps_opts [type: :utc_datetime_usec, inserted_at: :created_at]

  schema "employees" do
    field(:user_id, UUID)
    field(:role, :string)

    timestamps()
  end
end
