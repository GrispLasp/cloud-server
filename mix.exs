defmodule Cloudserver.MixProject do
  use Mix.Project

  def project do
    [
      app: :cloudserver,
      version: "0.1.0",
      elixir: "~> 1.6.5",
      start_permanent: Mix.env() == :prod,
      deps: deps()
      # dialyzer: [
      #   plt_add_deps: :transitive,
      #   flags: [:unmatched_returns, :error_handling, :race_conditions, :no_opaque],
      #   paths: ["_build/dev/lib/webserver/ebin"],
      #   dialyzer: [ignore_warnings: "dialyzer.ignore-warnings"]
      # ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {Cloudserver, []},
      applications: [
        :numerix,
        :gen_stage,
        :flow,
        :cowboy,
        :plug,
        :partisan,
        :lasp,
        :node
      ],
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:cowboy, "~> 2.4.0"},
      {:lasp, "~> 0.8.2", override: true},
      {:lager, git: "https://github.com/erlang-lager/lager.git", branch: "master", override: true},
      # {:types, "~> 0.1.8", override: true},
      {:partisan, git: "https://github.com/GrispLasp/partisan.git", override: true},
      {:node, git: "https://github.com/GrispLasp/node.git", branch: "master-cloud"},
     #{:node, path: "/home/alex/Desktop/thesis/GrispLasp/node"},
      {:poison, "~> 3.1"},
      {:plug, "~> 1.5.1"},
      # {:cors_plug, "~> 1.5"},
      {:numerix, "~> 0.5.1"},
      {:distillery, "~> 1.5", runtime: false},
      # {:dialyxir, "~> 0.5", only: [:dev], runtime: false}
    ]
  end
end
