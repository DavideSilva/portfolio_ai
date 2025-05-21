defmodule PortfolioAi.Contracts.USDC do
  @contract_address "0xA0B86991C6218B36C1D19D4A2E9EB0CE3606EB48"

  def balance_of(address) do
    with {:ok, balance} <-
           Ethers.Contracts.ERC20.balance_of(address)
           |> Ethers.call(to: @contract_address) do
      div(balance, 1_000_000) |> Integer.to_string()
    end
  end

  def symbol() do
    Ethers.Contracts.ERC20.symbol()
    |> Ethers.call(to: @contract_address)
  end

  def name do
    client = Exth.Rpc.new_client(:http, rpc_url: "https://ethereum-rpc.publicnode.com")

    with request <-
           Exth.Rpc.request("eth_call", [
             %{to: @contract_address, data: "0x06fdde03"},
             "latest"
           ]),
         {:ok, response} <- Exth.Rpc.send(client, request),
         ascii <- parse_response_to_ascii(response) do
      ascii
    end
  end

  def fetch_usdc_balance(address) do
    with {:ok, response} <-
           PortfolioAi.Tools.call(%{
             to: "0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48",
             data: "0x70a08231#{pad_address(address)}"
           }),
         trimmed <- response |> String.trim_leading("0x"),
         {balance, _} <- trimmed |> Integer.parse(16) do
      balance / 1_000_000
    end
  end

  defp parse_response_to_ascii(response) do
    {:ok, bin} =
      response.result
      |> String.trim_leading("0x")
      |> Base.decode16(case: :mixed)

    <<_offset::binary-size(32), str_len::unsigned-integer-size(256), str_data::binary>> = bin

    binary_part(str_data, 0, str_len)
  end

  defp pad_address(address) do
    address
    |> String.replace_prefix("0x", "")
    |> String.downcase()
    |> String.pad_leading(64, "0")
  end
end
