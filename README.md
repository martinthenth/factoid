# Factoid

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
