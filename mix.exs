defmodule Fact.MixProject do
  use Mix.Project

  @version "0.2.0"
  @source_url "https://github.com/martinthenth/fact"
  @changelog_url "https://github.com/martinthenth/fact/blob/main/CHANGELOG.md"

  def project do
    [
      app: :fact,
      version: @version,
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: "A test fixtures library based on Ecto",
      source_ref: @version,
      source_url: @source_url,
      docs: docs(),
      package: package()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:ecto_sql, "~> 3.9"},
      {:credo, "~> 1.6", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.0", only: [:dev], runtime: false},
      {:ex_doc, "~> 0.27", only: :dev, runtime: false},
      {:postgrex, ">= 0.0.0", only: :test}
    ]
  end

  defp package do
    [
      maintainers: ["Martin Nijboer"],
      licenses: ["MIT"],
      links: %{"GitHub" => @source_url, "Changelog" => @changelog_url}
    ]
  end

  defp docs do
    [
      main: "Fact",
      extras: ["README.md"]
    ]
  end
end
