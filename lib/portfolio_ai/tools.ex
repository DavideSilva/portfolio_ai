defmodule PortfolioAi.Tools do
  use Exth.Provider,
    otp_app: :portfolio_ai,
    transport_type: :http,
    rpc_url: "https://ethereum-rpc.publicnode.com"

  alias PortfolioAi.Contracts.USDC
  alias Decimal

  def fetch_usdc_balance(address) do
    USDC.balance_of(address)
  end

  def fetch_eth_balance(address) do
    with {:ok, balance} <- address |> __MODULE__.get_balance(),
         trimmed <- String.trim_leading(balance, "0x"),
         wei <- String.to_integer(trimmed, 16),
         eth <- wei_to_eth(wei) do
      "#{eth} ETH"
    end
  end

  defp wei_to_eth(wei) do
    wei
    |> Decimal.new()
    |> Decimal.div(Decimal.new(1_000_000_000_000_000_000))
    |> Decimal.round(6)
    |> Decimal.to_string()
    |> String.to_float()
  end
end
