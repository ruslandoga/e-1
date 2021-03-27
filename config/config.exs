import Config

config :e, ecto_repos: [E.Repo]

config :phoenix, :json_library, Jason

config :sentry,
  enable_source_code_context: true,
  root_source_code_paths: [File.cwd!()]

import_config "#{config_env()}.exs"
