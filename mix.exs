defmodule Restnull.Mixfile do
  use Mix.Project

  def project do
    [ app: :restnull,
      version: "0.0.1",
      elixir: "~> 0.12.5",
      deps: deps ]
  end

  def application do
    [
      mod: { Restnull, [] },
      applications: [:kernel, :stdlib, :cowboy]
    ]
  end

  defp deps do
    [
      {:cowboy, github: "extend/cowboy"},
      {:jsex, github: "talentdeficit/jsex"}
    ]
  end
end
