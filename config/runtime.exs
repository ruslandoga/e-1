import Config

config :e, Oban,
  repo: E.Repo,
  plugins: [Oban.Plugins.Pruner],
  queues: [default: 10, email: 50]

if config_env() == :test do
  config :e, Oban, queues: false, plugins: false
end
