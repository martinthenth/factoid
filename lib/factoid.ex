defmodule Factoid do
  @moduledoc ~S"""
  Documentation for `Factoid`.

  Factoid is a library for generating test data using factories build on Ecto.Schemas.

  It's similar to [ExMachina](https://github.com/thoughtbot/ex_machina) but it is not a drop-in
  replacement. Where ExMachina builds and keeps associations in the returned records, Factoid drops
  the associations and keeps the associated `id` fields. This opinionated approach helps building
  simpler tests.

  ## Installation

  Add `factoid` to the list of dependencies in `mix.exs`:

  ```elixir
  def deps do
    [{:factoid, "~> 0.1"}]
  end
  ```

  ## Usage

  Define a factory module that uses the `Factoid` behaviour, select the repo module, and define
  `build/2` functions for each factory.

  ```elixir
  def App.Factory do
    @behaviour Factoid

    use Factoid, repo: App.Repo

    alias App.Schemas.User
    alias App.Schemas.UserAvatar

    @impl Factoid
    def build(factory, attrs \\ %{})

    def build(:user, attrs) do
      %User{
        first_name: "Jane",
        last_name: "Doe",
        email_address: "jane-#{unique_integer()}@example.com",
      }
      |> Map.merge(attrs)
    end

    def build(:user_avatar, attrs) do
      %UserAvatar{
        user: build(:user)
      }
      |> Map.merge(attrs)
    end
  end
  ```

  In your tests you can import your factory and use it to create test data.

  ```elixir
  def App.ModuleTest do
    use DataCase

    import App.Factory

    alias App.Repo
    alias App.Schemas.User

    test "creates a user" do
      user_1 = insert(:user)
      user_2 = insert(:user, name: "John")

      assert user_1 != user_2
      assert user_1 == Repo.get(User, user_1.id)
      assert user_2.name == "John"
    end
  end
  ```
  """

  @typedoc false
  @type factory_name :: atom()

  @typedoc false
  @type record :: struct()

  @typedoc false
  @type field :: atom()

  @typedoc false
  @type value :: term()

  @typedoc false
  @type attrs :: map() | keyword()

  @doc """
  Builds a record.
  """
  @callback build(factory_name()) :: term()

  @doc """
  Builds a record with attributes.
  """
  @callback build(factory_name(), attrs()) :: term()

  @doc false
  defmacro __using__(opts) do
    quote bind_quoted: [opts: opts] do
      import Factoid, only: [insert: 4]

      @repo Keyword.get(opts, :repo)

      @typedoc false
      @type factory_name :: atom()

      @typedoc false
      @type record :: struct()

      @typedoc false
      @type attrs :: map() | keyword()

      @doc """
      Inserts a record with attributes.
      """
      @spec insert(factory_name(), attrs()) :: record()
      def insert(factory_name, attrs \\ %{}) do
        insert(@repo, factory_name, &build/2, attrs)
      end

      @doc """
      Generates a systemically unique integer.
      """
      def unique_integer, do: Factoid.unique_integer()

      @doc """
      Generates a UUID.
      """
      def unique_uuid, do: Factoid.unique_uuid()
    end
  end

  @doc """
  Inserts a record with attributes.
  """
  @spec insert(module(), factory_name(), fun(), attrs()) :: record()
  def insert(repo, factory_name, build, attrs \\ %{})

  def insert(repo, factory_name, build, attrs) when is_map(attrs) do
    factory_name
    |> build.(attrs)
    |> repo.insert!(returning: true)
    |> drop_associations()
  end

  def insert(repo, factory_name, build, attrs) when is_list(attrs),
    do: insert(repo, factory_name, build, Map.new(attrs))

  @doc """
  Generates a systemically unique integer.
  """
  @spec unique_integer :: non_neg_integer()
  def unique_integer, do: System.unique_integer([:positive])

  @doc """
  Generates a UUID.
  """
  @spec unique_uuid :: Ecto.UUID.t()
  def unique_uuid, do: Ecto.UUID.generate()

  @spec drop_associations(record()) :: record()
  defp drop_associations(%{__struct__: struct} = schema) do
    struct.__schema__(:associations)
    |> Enum.reduce(schema, fn association, schema ->
      %{schema | association => build_not_loaded(struct, association)}
    end)
  end

  defp build_not_loaded(struct, association) do
    %{
      cardinality: cardinality,
      field: field,
      owner: owner
    } = struct.__schema__(:association, association)

    %Ecto.Association.NotLoaded{
      __cardinality__: cardinality,
      __field__: field,
      __owner__: owner
    }
  end
end
