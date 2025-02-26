import Config

secret_key_base = System.get_env("SECRET_KEY_BASE") || "default_dev_secret_key"

config :vantage, Vantage.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "db",
  database: "vantage_dev",
  pool_size: 10,
  ssl: false,
  show_sensitive_data_on_connection_error: true

config :vantage, VantageWeb.Endpoint,
  http: [ip: {0, 0, 0, 0}, port: 4000],
  url: [host: "localhost", port: 4000],
  secret_key_base: secret_key_base,
  server: true,
  check_origin: false,
  cache_static_manifest: "priv/static/cache_manifest.json"

config :logger, level: :info

config :phoenix, :stacktrace_depth, 5
config :phoenix, :plug_init_mode, :runtime

config :swoosh, :api_client, false
