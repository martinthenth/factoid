defmodule Fact.Repo.Migrations.CreateEmployeesTable do
  use Ecto.Migration

  def change do
    create table(:employees, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :user_id, references(:users), null: false
      add :role, :string

      timestamps()
    end
  end
end
