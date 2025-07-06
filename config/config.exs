# config/config.exs
import Config

config :logger,
  level: :debug,
  backends: [:console]

config :logger, :console,
  format: "$date $time [$level] $metadata$message\n",
  metadata: [:module, :function]
