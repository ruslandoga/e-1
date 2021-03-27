import Config

config :e, TWeb.Endpoint,
  render_errors: [view: TWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: T.PubSub,
  live_view: [signing_salt: "uAv3ihGH"]

# secret_key_base: "ZQO/97cVlN6h+1A+w4oFZGVphqoPlVb+b5wYLx37ETARyl9azepMUOPkFlce6iZG",

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :logger,
  backends: [:console, Sentry.LoggerBackend]

config :sentry,
  environment_name: config_env(),
  included_environments: [:prod]

config :logger, Sentry.LoggerBackend,
  level: :warn,
  capture_log_messages: true,
  # [:cowboy] by default
  excluded_domains: []

config :e, Oban,
  repo: E.Repo,
  plugins: [Oban.Plugins.Pruner],
  queues: [default: 10, email: 50]

config :ex_aws,
  json_codec: Jason,
  region: "eu-central-1"

if config_env() == :prod do
  config :e, T.Twilio,
    account_sid: System.fetch_env!("TWILIO_ACCOUNT_SID"),
    key_sid: System.fetch_env!("TWILIO_KEY_SID"),
    auth_token: System.fetch_env!("TWILIO_AUTH_TOKEN")

  config :e, run_migrations_on_start?: true

  config :e, E.Repo,
    url: System.fetch_env!("DATABASE_URL"),
    pool_size: String.to_integer(System.get_env("POOL_SIZE") || "20")

  host = System.fetch_env!("HOST")

  config :e, E.Mailer, our_address: "notify@#{host}"

  config :e, :dashboard,
    username: System.fetch_env!("DASHBOARD_USERNAME"),
    password: System.fetch_env!("DASHBOARD_PASSWORD")

  config :e, EWeb.Endpoint,
    # For production, don't forget to configure the url host
    # to something meaningful, Phoenix uses this information
    # when generating URLs.
    url: [host: host, port: 443],
    http: [
      # Enable IPv6 and bind on all interfaces.
      # Set it to {0, 0, 0, 0, 0, 0, 0, 1} for local network only access.
      ip: {0, 0, 0, 0, 0, 0, 0, 0},
      port: String.to_integer(System.get_env("PORT") || "4000")
    ],
    secret_key_base: System.fetch_env!("SECRET_KEY_BASE"),
    server: true

  # Do not print debug messages in production
  config :logger, level: :info

  config :sentry,
    dsn: System.fetch_env!("SENTRY_DSN")
end

if config_env() == :dev do
  # Configure your database
  config :e, E.Repo,
    username: "postgres",
    password: "postgres",
    database: "e_dev",
    hostname: "localhost",
    # url: System.fetch_env!("DATABASE_URL"),
    show_sensitive_data_on_connection_error: true,
    pool_size: 10

  # For development, we disable any cache and enable
  # debugging and code reloading.
  #
  # The watchers configuration can be used to run external
  # watchers to your application. For example, we use it
  # with webpack to recompile .js and .css sources.
  config :e, EWeb.Endpoint,
    http: [port: 4000],
    debug_errors: true,
    check_origin: false,
    secret_key_base: "G3Ln+/DGlLRcc0cFikD44j8AS16t7ab5g0CjqhGBkOz2ol5GjHemYelcDWDEjkw5",
    url: [host: "localhost"],
    watchers: [
      node: [
        "node_modules/webpack/bin/webpack.js",
        "--mode",
        "development",
        "--watch-stdin",
        cd: Path.expand("../assets", __DIR__)
      ]
    ]

  # Watch static and templates for browser reloading.
  config :e, EWeb.Endpoint,
    live_reload: [
      patterns: [
        ~r"priv/static/.*(js|css|png|jpeg|jpg|gif|svg)$",
        ~r"priv/gettext/.*(po)$",
        ~r"lib/e_web/(live|views)/.*(ex)$",
        ~r"lib/e_web/templates/.*(eex)$"
      ]
    ]

  config :e, E.Twilio,
    account_sid: System.fetch_env!("TWILIO_ACCOUNT_SID"),
    key_sid: System.fetch_env!("TWILIO_KEY_SID"),
    auth_token: System.fetch_env!("TWILIO_AUTH_TOKEN")

  config :e, E.Mailer,
    adapter: Bamboo.LocalAdapter,
    #   #   adapter: Bamboo.SesAdapter,
    #   #   ex_aws: [region: "eu-central-1"],
    our_address: "notify@example.com"

  config :e, :dashboard,
    username: System.fetch_env!("DASHBOARD_USERNAME"),
    password: System.fetch_env!("DASHBOARD_PASSWORD")

  # Do not include metadata nor timestamps in development logs
  config :logger, :console, format: "[$level] $message\n"
end

if config_env() == :test do
  # Configure your database
  #
  # The MIX_TEST_PARTITION environment variable can be used
  # to provide built-in test partitioning in CI environment.
  # Run `mix help test` for more information.
  config :e, E.Repo,
    username: "postgres",
    password: "postgres",
    database: "t_test#{System.get_env("MIX_TEST_PARTITION")}",
    hostname: "localhost",
    pool: Ecto.Adapters.SQL.Sandbox

  # We don't run a server during test. If one is required,
  # you can enable the server option below.
  config :e, EWeb.Endpoint,
    secret_key_base: "G3Ln+/DGlLRcc0cFikD44j8AS16t7ab5g0CjqhGBkOz2ol5GjHemYelcDWDEjkw5",
    url: [host: "localhost"],
    http: [port: 4002],
    server: false

  config :e, Oban, crontab: false, queues: false, plugins: false

  config :e, E.Mailer, adapter: Bamboo.TestAdapter, our_address: "notify@example.com"

  # Print only warnings and errors during test
  config :logger, level: :warn

  config :ex_aws,
    access_key_id: "AWS_ACCESS_KEY_ID",
    secret_access_key: "AWS_SECRET_ACCESS_KEY"
end
