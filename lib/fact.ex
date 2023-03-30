defmodule Fact do
  @moduledoc ~S"""
  Documentation for `Fact`.
  """

  defmacro __using__(opts) do
    quote bind_quoted: [opts: opts] do
      @repo Keyword.get(opts, :repo)

      @doc """
      Generate a systemically unique integer.
      """
      @spec unique_integer :: non_neg_integer()
      def unique_integer, do: System.unique_integer([:positive])

      @doc """
      Builds a fixture for a record that will be inserted later.
      """
      def fixture(name), do: {:fixture, name}

      @doc """
      Builds a fixture for a record that will be inserted later.
      """
      def fixture(name, field), do: {:fixture, name, field}

      @doc """
      Inserts the fixture.
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
      Inserts the list of fixtures.
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
    end
  end
end
