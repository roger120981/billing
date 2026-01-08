defmodule BillingWeb.ThemeController do
  use BillingWeb, :controller

  alias Billing.StoreScope
  alias Billing.Settings

  def index(conn, _params) do
    store_scope = StoreScope.get_store_scope()

    if store_scope do
      settings = Settings.get_setting!(store_scope)

      conn
      |> assign(:settings, settings)
      |> put_resp_content_type("text/css")
      |> render("index.css")
    else
      conn
      |> put_resp_content_type("text/css")
      |> send_resp(200, "")
    end
  end
end
