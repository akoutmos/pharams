defmodule Pharams.MixProject do
  use Mix.Project

  def project do
    [
      app: :pharams,
      version: "0.1.0",
      elixir: "~> 1.6",
      name: "Pharams",
      source_url: "https://github.com/akoutmos/pharams",
      homepage_url: "https://hex.pm/packages/pharam",
      description: "Validate parameters in Phoenix with ease using Ecto.Schema",
      start_permanent: Mix.env() == :prod,
      package: package(),
      deps: deps()
    ]
  end

  defp package() do
    [
      name: "pharams",
      files: ~w(lib .formatter.exs mix.exs README.md LICENSE CHANGELOG.md),
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/akoutmos/pharams"}
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:phoenix, "~> 1.3"},
      {:plug, "~> 1.6"},
      {:ecto, "~> 2.0"},
      {:ex_doc, "~> 0.17", only: :dev, runtime: false}
    ]
  end
end
