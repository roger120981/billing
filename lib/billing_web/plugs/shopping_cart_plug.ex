defmodule BillingWeb.Plugs.ShoppingCartPlug do
  import Plug.Conn

  alias Phoenix.Token

  def init(_) do
  end

  def call(conn, _params) do
    cart_token = Token.sign(conn, "cart_token", DateTime.utc_now())

    put_session(conn, :cart_token, cart_token)
  end
end
