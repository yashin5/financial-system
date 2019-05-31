# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

config :financial_system, file: "currency_rate.json"

config :financial_system, :currency_finder, FinancialSystem.Currency.CurrencyImpl

config :financial_system, FinancialSystem.Repo,
  database: "account_repository",
  username: "ysantos",
  password: "@dmin123",
  hostname: "localhost"

config :financial_system, ecto_repos: [FinancialSystem.Repo]

# This configuration is loaded before any dependency and is restricted
# to this project. If another project depends on this project, this
# file won't be loaded nor affect the parent project. For this reason,
# if you want to provide default values for your application for
# third-party users, it should be done in your "mix.exs" file.

# You can configure your application as:
#
#     config :financial_system, key: :value
#
# and access this configuration in your application as:
#
#     Application.get_env(:financial_system, :key)
#
# You can also configure a third-party app:
#
#     config :logger, level: :info
#

# It is also possible to import configuration files, relative to this
# directory. For example, you can emulate configuration per environment
# by uncommenting the line below and defining dev.exs, test.exs and such.
# Configuration from the imported file will override the ones defined
# here (which is why it is important to import them last).

case Mix.env() do
  :dev -> nil
  _ -> import_config "#{Mix.env()}.exs"
end
