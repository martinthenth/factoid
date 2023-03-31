defmodule Fact do
  @moduledoc ~S"""
  Documentation for `Fact`.
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

  @optional_callbacks build: 1

  @doc false
  defmacro __using__(opts) do
    quote bind_quoted: [opts: opts] do
      import Fact, only: [fixture: 1, fixture: 2, unique_integer: 0]

      @repo Keyword.get(opts, :repo)

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
      Inserts a record with attributes.
      """
      @spec insert(factory_name(), attrs()) :: record()
      def insert(factory_name, attrs \\ %{})

      def insert(factory_name, attrs) when is_map(attrs) do
        struct = build(factory_name, attrs)

        struct
        |> Map.to_list()
        |> Enum.reduce(struct, fn
          {field, {:fixture, inner_factory_name}}, acc ->
            Map.put(acc, field, insert_and_get(inner_factory_name))

          {field, {:fixture, inner_factory_name, inner_field}}, acc ->
            Map.put(acc, field, insert_and_get(inner_factory_name, inner_field))

          {field, value}, acc ->
            acc
        end)
        |> @repo.insert!(returning: true)
      end

      def insert(factory_name, attrs) when is_list(attrs) do
        insert(factory_name, Map.new(attrs))
      end

      @spec insert_and_get(factory_name(), field()) :: value()
      defp insert_and_get(factory_name, field \\ :id) do
        factory_name
        |> insert()
        |> Map.get(field)
      end
    end
  end

  @doc """
  Builds a fixture for a record and returns the value of the primary key.
  """
  @spec fixture(factory_name()) :: {:fixture, factory_name()}
  def fixture(factory_name), do: {:fixture, factory_name}

  @doc """
  Builds a fixture for a record and returns the value of the field.
  """
  @spec fixture(factory_name(), field()) :: {:fixture, factory_name(), field()}
  def fixture(factory_name, field), do: {:fixture, factory_name, field}

  @doc """
  Generates a systemically unique integer.
  """
  @spec unique_integer :: non_neg_integer()
  def unique_integer, do: System.unique_integer([:positive])
end
