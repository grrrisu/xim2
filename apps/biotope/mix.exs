defmodule Biotope.MixProject do
  use Mix.Project

  def project do
    [
      app: :biotope,
      version: "0.1.0",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.15",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Biotope.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:phoenix_pubsub, "~> 2.1"},
      {:ximula, git: "https://github.com/grrrisu/ximula.git", override: true, app: false}
      # {:ximula, path: "../../../ximula"}
    ]
  end
end
