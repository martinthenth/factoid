defmodule FactoidTest do
  use ExUnit.Case
  use Factoid, repo: Factoid.Repo

  alias Ecto.UUID
  alias Factoid.Repo
  alias Factoid.Schemas.Employee
  alias Factoid.Schemas.User

  def build(:user) do
    %User{
      name: "Jane",
      age: 28
    }
  end

  def build(:user, attrs) do
    %User{
      name: "Jane",
      age: 28
    }
    |> Map.merge(attrs)
  end

  def build(:employee, attrs) do
    %Employee{
      user: build(:user),
      role: "admin"
    }
    |> Map.merge(attrs)
  end

  describe "__using__/1" do
    test "insert/1 - creates a record" do
      user = insert(:user)

      assert user.name == "Jane"
      assert user.age == 28
      assert user.created_at
      assert user.updated_at

      assert user == Repo.get(User, user.id)
    end

    test "insert/2 - creates a record with the given attributes" do
      user = insert(:user, name: "Tarzan", age: 32)

      assert user.name == "Tarzan"
      assert user.age == 32
      assert user.created_at
      assert user.updated_at

      assert user == Repo.get(User, user.id)
    end

    test "insert/2 - creates a record with an association" do
      employee = insert(:employee)

      assert employee.user_id
      assert %Ecto.Association.NotLoaded{} = employee.user
      assert %User{} = Repo.get(User, employee.user_id)

      assert employee == Repo.get(Employee, employee.id)
    end

    test "insert/2 - overwrites the id" do
      id = UUID.generate()
      user = insert(:user, id: id)

      assert user.id == id
      assert user == Repo.get(User, id)
    end

    test "insert/2 - overwrites the association" do
      employee = insert(:employee, user: build(:user))

      assert employee.user_id
      assert %Ecto.Association.NotLoaded{} = employee.user
      assert %User{} = Repo.get(User, employee.user_id)
    end

    test "insert/2 - overwrites the association with an existing record" do
      user = insert(:user)
      employee = insert(:employee, user: user)

      assert employee.user_id
      assert %Ecto.Association.NotLoaded{} = employee.user
      assert user == Repo.get(User, employee.user_id)
    end

    test "insert/2 - raises on overwriting the association's id" do
      assert_raise ArgumentError, fn ->
        user = insert(:user)
        _employee = insert(:employee, user_id: user.id)
      end
    end

    test "unique_integer/0 - generates an integer" do
      assert is_integer(unique_integer())
    end

    test "unique_uuid/0 - generates an UUID" do
      assert is_binary(unique_uuid())
    end
  end
end
