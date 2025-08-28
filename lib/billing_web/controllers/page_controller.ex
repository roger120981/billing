defmodule BillingWeb.PageController do
  use BillingWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
