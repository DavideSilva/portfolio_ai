defmodule PortfolioAiWeb.Api.ChatController do
  alias PortfolioAi.Openai
  use PortfolioAiWeb, :controller

  def index(conn, params) do
    input =
      Map.get(params, "chat")
      |> IO.inspect()

    message =
      Openai.chat([input])
      |> IO.inspect()

    json(conn, %{message: message})
  end
end
