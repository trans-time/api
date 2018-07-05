# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :api,
  ecto_repos: [Api.Repo]

config :api, Api.Repo, migration_timestamps: [type: :utc_datetime]

# Configures the endpoint
config :api, ApiWeb.Endpoint,
  http: [compress: true],
  url: [host: "localhost"],
  secret_key_base: "yh0q8V9izXEh5hrGED8ZGKyP3SPKFBOktZA4YTpgCOgvmngJu/dX96Lp3PQ1hPhG",
  render_errors: [view: ApiWeb.ErrorView, accepts: ~w(html json json-api)],
  pubsub: [name: Api.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :phoenix, :format_encoders,
  "json-api": Poison

config :mime, :types, %{
  "application/vnd.api+json" => ["json-api"]
}

config :phoenix, PhoenixExample.Endpoint,
  render_errors: [view: PhoenixExample.ErrorView, accepts: ~w(html json json-api)]

config :ja_resource, repo: Api.Repo

config :ueberauth, Ueberauth,
  providers: [
    identity: {Ueberauth.Strategy.Identity, [
      callback_methods: ["POST"],
      param_nesting: ["data", "attributes"]
    ]}
  ]

config :arc,
  storage: Arc.Storage.S3,
  bucket: "trans-time-user-uploads--development"

config :api, Api.Accounts.Guardian,
  issuer: "api",
  secret_key: "iZYJkEAaViic3E24ihM6n587JYXBkXdYSKHZkxfe2s9HoyZ0GNW9p4u7nJv6IdtN"

config :api, Api.Scheduler,
  jobs: [
    # Runs every midnight:
    {"@daily", {Api.CronJobs.UnbanUsers, :call, []}},
    {"@daily", {Api.CronJobs.UnlockComments, :call, []}}
  ]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
