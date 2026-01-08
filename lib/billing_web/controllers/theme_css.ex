defmodule BillingWeb.ThemeCSS do
  @moduledoc """
  This module contains pages rendered by ThemeController.

  See the `theme_html` directory for all templates available.
  """
  use BillingWeb, :html

  embed_templates "theme_html/*"
end
