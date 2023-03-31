defmodule Fact.Application do
  @moduledoc false

  use Application

  @impl Application
  def start(_type, _args) do
    children = [Fact.Repo]
    opts = [strategy: :one_for_one, name: Fact.Supervisor]

    Supervisor.start_link(children, opts)
  end
end
