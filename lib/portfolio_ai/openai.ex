defmodule PortfolioAi.Openai do
  alias OpenaiEx.ChatMessage
  alias OpenaiEx.Chat

  defdelegate fetch_eth_balance(address), to: PortfolioAi.Tools
  defdelegate fetch_usdc_balance(address), to: PortfolioAi.Tools

  @model "gpt-4.1-nano"

  def api_key do
    System.fetch_env!("OPENAI_API_KEY")
  end

  def get_client() do
    api_key()
    |> OpenaiEx.new()
  end

  def chat(messages, model \\ @model) do
    prompt =
      Chat.Completions.new(
        model: model,
        messages: [ChatMessage.user(messages)] |> Enum.reverse()
      )

    {:ok, response} = get_client() |> Chat.Completions.create(prompt)
    response["choices"] |> Enum.at(0) |> Map.get("message") |> Map.get("content")
  end

  def continue_chat_with_tools(messages, model \\ @model) do
    prompt =
      Chat.Completions.new(
        model: model,
        messages: messages |> Enum.reverse()
      )

    {:ok, response} = get_client() |> Chat.Completions.create(prompt)
    response["choices"] |> Enum.at(0) |> Map.get("message") |> Map.get("content")
  end

  def chat_with_tools(messages, model \\ @model) do
    msgs = [ChatMessage.user(messages)]

    prompt =
      Chat.Completions.new(
        model: model,
        messages: msgs,
        tools: tooling(),
        tool_choice: "auto"
      )

    {:ok, response} = get_client() |> Chat.Completions.create(prompt)
    tool_calling(msgs, response)
  end

  def tool_calling(messages, fn_response) do
    fn_message = fn_response["choices"] |> Enum.at(0) |> Map.get("message")

    tool_calls = fn_message |> Map.get("tool_calls")
    tool_results = Enum.map(tool_calls, &call_tool/1)

    latest_msgs = [tool_results | [fn_message | messages]] |> List.flatten()
    continue_chat_with_tools(latest_msgs)
  end

  defp call_tool(tool_call) do
    tool_id = tool_call |> Map.get("id")
    fn_call = tool_call |> Map.get("function")

    fn_name = fn_call["name"]
    fn_args = fn_call["arguments"] |> Jason.decode!()

    address = fn_args["address"]

    fn_value =
      case fn_name do
        "fetch_eth_balance" -> fetch_eth_balance(address)
        "fetch_usdc_balance" -> fetch_usdc_balance(address)
      end

    ChatMessage.tool(tool_id, fn_name, fn_value)
  end

  def tooling() do
    [
      %{
        "type" => "function",
        "function" => %{
          "name" => "fetch_eth_balance",
          "description" => "Fetch ETH balance for address",
          "parameters" => %{
            "type" => "object",
            "properties" => %{
              "address" => %{
                "type" => "string",
                "description" => "wallet address to fetch ETH balance for"
              }
            },
            "required" => ["address"]
          }
        }
      },
      %{
        "type" => "function",
        "function" => %{
          "name" => "fetch_usdc_balance",
          "description" => "Fetch USDC balance for address",
          "parameters" => %{
            "type" => "object",
            "properties" => %{
              "address" => %{
                "type" => "string",
                "description" => "wallet address to fetch USDC balance for"
              }
            },
            "required" => ["address"]
          }
        }
      }
    ]
  end
end
