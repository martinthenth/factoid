defmodule Factoid do
  @moduledoc ~S"""
  Documentation for `Factoid`.
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
      import Factoid

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
        factory_name
        |> build(attrs)
        |> @repo.insert!(returning: true)
        |> clear_associations()
      end

      def insert(factory_name, attrs) when is_list(attrs),
        do: insert(factory_name, Map.new(attrs))

      @doc """
      Generates a systemically unique integer.
      """
      @spec unique_integer :: non_neg_integer()
      def unique_integer, do: System.unique_integer([:positive])

      @doc """
      Generates an UUID.
      """
      @spec unique_uuid :: Ecto.UUID.t()
      def unique_uuid, do: Ecto.UUID.generate()
    end
  end

  def clear_associations(%{__struct__: struct} = schema) do
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
