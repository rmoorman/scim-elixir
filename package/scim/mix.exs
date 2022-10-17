defmodule SCIM.MixProject do
  use Mix.Project

  def project() do
    [
      app: :scim,
      version: "0.0.1",
      elixir: "~> 1.13",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description:
        "Utilities for integrating the System for Cross-domain Identity Management (SCIM) into your application.",
      package: package(),
      source_url: "https://github.com/rmoorman/scim-elixir"
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application() do
    [
      extra_applications: [:logger]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help deps" to learn about dependencies.
  defp deps() do
    [
      {:plug, ">= 1.13.0"},
      {:abnf_parsec, "~> 1.0", runtime: false},
      {:decimal, "~> 2.0"},

      # dependencies for the phoenix integration
      {:phoenix, "~> 1.6"},
      {:jason, "~> 1.0"},

      # dependencies for the ecto integration
      {:ecto, "~> 3.8"},

      # dev and test utilities
      {:dialyxir, "~> 1.0", only: [:dev], runtime: false},
      {:mix_test_watch, "~> 1.0", only: [:dev, :test], runtime: false},
      {:ecto_sqlite3, "~> 0.8.0", only: [:test], runtime: false},

      # docs
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false}
    ]
  end

  defp package() do
    [
      files: ~w(lib .formatter.exs mix.exs README* LICENSE* CHANGELOG*),
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/rmoorman/scim-elixir"}
    ]
  end
end
