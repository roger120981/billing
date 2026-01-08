defmodule BillingWeb.LiveSessions.StoreSession do
  import Phoenix.Component
  import Ecto.Query, warn: false

  alias Billing.Accounts.User
  alias Billing.Accounts.Scope
  alias Billing.Settings
  alias Billing.StoreScope

  defmodule StoreNotFoundError do
    use Gettext, backend: BillingWeb.Gettext

    defexception message: gettext("Store not available"), plug_status: 404
  end

  def on_mount(:mount_store_scope, _params, %{"cart_uuid" => cart_uuid}, socket) do
    socket
    |> assign_new(:cart_uuid, fn -> cart_uuid end)
    |> assign_new(:store_scope, fn -> StoreScope.get_store_scope() end)
    |> handle_store_scope()
  end

  def handle_store_scope(%{assigns: %{store_scope: %Scope{user: %User{}}}} = socket) do
    new_socket =
      assign_new(socket, :settings, fn -> Settings.get_setting!(socket.assigns.store_scope) end)

    {:cont, new_socket}
  end

  def handle_store_scope(_socket) do
    raise StoreNotFoundError
  end
end
