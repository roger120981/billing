defmodule BillingWeb.LiveSessions.ShoppingCartSession do
  import Phoenix.Component

  def on_mount(:mount_session, _params, %{"cart_token" => cart_token}, socket) do
    {:cont, assign_new(socket, :cart_token, fn -> cart_token end)}
  end
end
