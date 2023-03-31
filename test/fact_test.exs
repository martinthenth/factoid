defmodule FactTest do
  use ExUnit.Case
  use Fact, repo: Fact.Repo

  alias Ecto.UUID
  alias Fact.Repo
  alias Fact.Schemas.Employee
  alias Fact.Schemas.User

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
      user_id: fixture(:user),
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
    end

    test "insert/2 - creates a record with the given attributes" do
      user = insert(:user, name: "Tarzan", age: 32)

      assert user.name == "Tarzan"
      assert user.age == 32
      assert user.created_at
      assert user.updated_at
    end

    test "insert/2 - creates a record with a fixture" do
      employee = insert(:employee)

      assert employee.user_id
      assert %User{} = Repo.get(User, employee.user_id)
    end

    test "insert/2 - overwrites the id" do
      id = UUID.generate()
      user = insert(:user, id: id)

      assert user.id == id
    end

    test "unique_integer/0 - generates an integer" do
      assert is_integer(unique_integer())
    end
  end

  describe "fixture/1" do
    test "false" do
      assert Fact.fixture(:user) == {:fixture, :user}
    end
  end

  describe "fixture/2" do
    test "false" do
      assert Fact.fixture(:user, name: "Jane") == {:fixture, :user, name: "Jane"}
    end
  end
end
