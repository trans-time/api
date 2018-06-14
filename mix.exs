defmodule Api.Mixfile do
  use Mix.Project

  def project do
    [
      app: :api,
      version: "0.0.1",
      elixir: "~> 1.4",
      elixirc_paths: elixirc_paths(Mix.env),
      compilers: [:phoenix, :gettext] ++ Mix.compilers,
      start_permanent: Mix.env == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {Api.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_),     do: ["lib", "factories"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:arc, "~> 0.8.0"},
      {:arc_ecto, "~> 0.7.0"},
      {:argon2_elixir, "~> 1.2"},
      {:comeonin, "~> 4.0"},
      {:corsica, "~> 1.0"},
      {:cowboy, "~> 1.0"},
      {:ex_aws, "~> 2.0", override: true},
      {:ex_aws_s3, "~> 2.0"},
      {:ex_machina, "~> 2.1"},
      {:faker, "~> 0.9", only: :dev},
      {:guardian, "~> 1.0"},
      {:gettext, "~> 0.11"},
      {:hackney, "~> 1.9"},
      {:indifferent, "~> 0.9"},
      {:ja_resource, "~> 0.3"},
      {:ja_serializer, "~> 0.12"},
      {:phoenix, "~> 1.3.0"},
      {:phoenix_pubsub, "~> 1.0"},
      {:phoenix_ecto, "~> 3.2"},
      {:poison, "~> 3.0"},
      {:postgrex, ">= 0.0.0"},
      {:phoenix_html, "~> 2.10"},
      {:phoenix_live_reload, "~> 1.0", only: :dev},
      {:quantum, "~> 2.2"},
      {:scrivener_ecto, "~> 1.3"},
      {:sweet_xml, "~> 0.6"},
      {:timex, "~> 3.0"},
      {:ueberauth, "~> 0.5"},
      {:ueberauth_identity, "~> 0.2"}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to create, migrate and run the seeds file at once:
  #
  #     $ mix ecto.setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      "test": ["ecto.create --quiet", "ecto.migrate", "test"]
    ]
  end
end
