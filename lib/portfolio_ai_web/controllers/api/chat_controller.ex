defmodule PortfolioAiWeb.Api.ChatController do
  alias PortfolioAi.Openai
  use PortfolioAiWeb, :controller

  def chat(conn, params) do
    message =
      Openai.chat(Map.get(params, "_json"))

    json(conn, %{message: message})
  end

  def chat_tools(conn, params) do
    message =
      Openai.chat(Map.get(params, "_json"))

    json(conn, %{message: message})
  end
end
