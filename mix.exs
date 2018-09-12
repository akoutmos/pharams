defmodule Pharams.MixProject do
  use Mix.Project

  def project do
    [
      app: :pharams,
      version: "0.1.0",
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      deps: deps()
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
      {:phoenix, "~> 1.3.4"},
      {:plug, "~> 1.6.2"},
      {:ecto, "2.2.10"}
    ]
  end
end
