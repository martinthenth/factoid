defmodule Fact do
  @moduledoc ~S"""
  Documentation for `Fact`.
  """

  @typedoc false
  @type factory_name :: atom()

  @typedoc false
  @type field :: atom()

  @typedoc false
  @type attrs :: map() | keyword()

  @callback build(factory_name()) :: term()
  @callback build(factory_name(), attrs()) :: term()

  @doc false
  defmacro __using__(opts) do
    quote bind_quoted: [opts: opts] do
      import Fact, only: [fixture: 1, fixture: 2]

      @repo Keyword.get(opts, :repo)

      @doc """
      Inserts the record.
      """
      @spec insert(atom(), map() | keyword()) :: struct()
      def insert(name, attrs \\ %{})

      def insert(name, attrs) when is_map(attrs) do
        struct = build(name, attrs)

        struct
        |> Map.to_list()
        |> Enum.reduce(struct, fn
          {field, {:fixture, inner_name}}, acc ->
            Map.put(acc, field, insert_and_get(inner_name))

          {field, {:fixture, inner_name, inner_field}}, acc ->
            Map.put(acc, field, insert_and_get(inner_name, inner_field))

          {field, value}, acc ->
            acc
        end)
        |> @repo.insert!(returning: true)
      end

      def insert(name, attrs) when is_list(attrs) do
        insert(name, Map.new(attrs))
      end

      @doc """
      Inserts the list of records.
      """
      @spec insert_all(atom, [map()]) :: [struct()]
      def insert_all(name, list_of_attrs \\ []) do
        {module, list_of_attrs} =
          Enum.reduce(list_of_attrs, {nil, []}, fn attrs, acc ->
            struct = build(name, attrs)
            attrs = Map.from_struct(struct)

            case acc do
              {nil, []} -> {struct.__struct__, [attrs]}
              {module, list} -> {module, [attrs | list]}
            end
          end)

        placeholders = %{timestamp: DateTime.utc_now()}

        module
        |> @repo.insert_all(list_of_attrs, placeholders: placeholders, returning: true)
        |> elem(1)
      end

      @doc """
      Generates a systemically unique integer.
      """
      @spec unique_integer :: non_neg_integer()
      def unique_integer, do: System.unique_integer([:positive])

      @spec insert_and_get(atom()) :: term()
      defp insert_and_get(name) do
        name
        |> insert()
        |> Map.get(:id)
      end

      @spec insert_and_get(atom(), atom()) :: term()
      defp insert_and_get(name, field) do
        name
        |> insert()
        |> Map.get(field)
      end
    end
  end

  @doc """
  Builds a fixture for a record to be inserted.
  """
  @spec fixture(factory_name()) :: {:fixture, factory_name()}
  def fixture(name), do: {:fixture, name}

  @doc """
  Builds a fixture for a record to be inserted.
  """
  @spec fixture(factory_name(), field()) :: {:fixture, factory_name(), field()}
  def fixture(name, field), do: {:fixture, name, field}
end
