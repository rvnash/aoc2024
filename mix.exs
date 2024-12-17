defmodule D01.MixProject do
  use Mix.Project

  def project do
    [
      app: :aoc,
      version: "0.1.0",
      elixir: "~> 1.17",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  defp deps do
    [
      {:arrays, "~> 2.1.1"},
      {:libgraph, "~> 0.16.0"}
    ]
  end
end
