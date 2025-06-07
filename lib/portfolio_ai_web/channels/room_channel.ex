defmodule PortfolioAiWeb.RoomChannel do
  alias PortfolioAi.Openai
  use PortfolioAiWeb, :channel

  @impl true
  def join("room:lobby", _payload, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_in("new_msg", payload, socket) do
    response = Openai.chat_with_tools(Map.get(payload, "body"))
    broadcast(socket, "reply", %{response: response})

    {:reply, {:ok, payload}, socket}
  end

  # Channels can be used in a request/response fashion
  # by sending replies to requests from the client
  @impl true
  def handle_in("ping", payload, socket) do
    {:reply, {:ok, payload}, socket}
  end

  # It is also common to receive messages from the client and
  # broadcast to everyone in the current topic (room:lobby).
  @impl true
  def handle_in("shout", payload, socket) do
    broadcast(socket, "shout", payload)
    {:noreply, socket}
  end
end
