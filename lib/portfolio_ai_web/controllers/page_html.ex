defmodule PortfolioAiWeb.PageHTML do
  @moduledoc """
  This module contains pages rendered by PageController.

  See the `page_html` directory for all templates available.
  """
  use PortfolioAiWeb, :html

  embed_templates "page_html/*"
end
