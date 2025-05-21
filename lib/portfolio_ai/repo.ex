defmodule PortfolioAi.Repo do
  use Ecto.Repo,
    otp_app: :portfolio_ai,
    adapter: Ecto.Adapters.Postgres
end
