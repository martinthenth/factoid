defmodule Fact.DataCase do
  @moduledoc false

  use ExUnit.CaseTemplate

  alias Ecto.Adapters.SQL.Sandbox

  using do
    quote do
      alias Fact.Repo

      import Ecto
      import Ecto.Changeset
      import Ecto.Query
      import Fact.DataCase
    end
  end

  setup tags do
    Fact.DataCase.setup_sandbox(tags)
    :ok
  end

  @doc false
  def setup_sandbox(tags) do
    pid = Sandbox.start_owner!(Fact.Repo, shared: not tags[:async])
    on_exit(fn -> Sandbox.stop_owner(pid) end)
  end

  @doc false
  def errors_on(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {message, opts} ->
      Regex.replace(~r"%{(\w+)}", message, fn _, key ->
        opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
      end)
    end)
  end
end
