# Factoid

Factoid is a library for generating test data using factories build on Ecto.Schemas.

It's similar to [ExMachina](https://github.com/thoughtbot/ex_machina) but it is not a drop-in
replacement. Where ExMachina builds and keeps associations in the returned records, Factoid drops
the associations and keeps the associated `id` fields. This helps us build simpler tests.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `factoid` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:factoid, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/factoid>.
