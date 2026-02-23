# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :tasx,
  namespace: TasxCore,
  ecto_repos: [TasxCore.Repo],
  generators: [timestamp_type: :utc_datetime, binary_id: true]

# Configure the endpoint
config :tasx, TasxWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [json: TasxWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: TasxCore.PubSub,
  live_view: [signing_salt: "a61kcm/n"]

# Configure the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :tasx, TasxCore.Mailer, adapter: Swoosh.Adapters.Local

# Configures a Json Web Token secret key
config :tasx, TasxCore.JsonWebToken,
  jwt_secret_key:
    System.get_env(
      "JWT_SECRET_KEY",
      "dE6p4Qy998PcdoICNTnGUe3gJQCwShFcApo2as5su2evp+fT90Z2xUgHkQoju7G+"
    )

# Configures the database timezone
config :elixir, :time_zone_database, Tz.TimeZoneDatabase

# Configure Elixir's Logger
config :logger, :default_formatter,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
