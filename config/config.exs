# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :opera,
  ecto_repos: [Opera.Repo],
  generators: [timestamp_type: :utc_datetime]

config :opera, :process_apps, [
  {"Home Loan", Opera.Processes.HomeLoanApp},
  {"Prepare Bill", Opera.Processes.PrepareBillApp},
  {"Payment Approval", Opera.Processes.PaymentApprovalApp},
  {"Invoice Receipt", Opera.Processes.InvoiceReceipt},
  {"Send Invoices", Opera.Processes.SendInvoices},
  {"Oban Timer Process", Opera.Processes.ObanTimerTaskProcess},
  {"Real Estate Showing", Opera.Processes.ShowRealEstate},
  {"Send Showing Contact Info", Opera.Processes.ShowRealEstate}
]

# Configures the endpoint
config :opera, OperaWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [html: OperaWeb.ErrorHTML, json: OperaWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: Opera.PubSub,
  live_view: [signing_salt: "GFMhfDfn"]

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :opera, Opera.Mailer, adapter: Swoosh.Adapters.Local

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.17.11",
  opera: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configure tailwind (the version is required)
config :tailwind,
  version: "3.4.3",
  opera: [
    args: ~w(
      --config=tailwind.config.js
      --input=css/app.css
      --output=../priv/static/assets/app.css
    ),
    cd: Path.expand("../assets", __DIR__)
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :opera, Oban,
  engine: Oban.Engines.Basic,
  queues: [default: 10],
  repo: Opera.Repo,
  plugins: [
    {Oban.Plugins.Cron, crontab: [
      {"0 */2 * * *", Opera.Workers.SendInvoicesWorker}
    ]}
  ]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
