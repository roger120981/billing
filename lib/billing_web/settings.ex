defmodule BillingWeb.Settings do
  import Plug.Conn

  alias Billing.Settings

  def fetch_settings(conn, _opts) do
    settings = Settings.get_setting!(conn.assigns.current_scope)

    assign(conn, :settings, settings)
  end

  def on_mount(:mount_settings, _params, _session, socket) do
    {:cont, mount_settings(socket)}
  end

  defp mount_settings(socket) do
    Phoenix.Component.assign_new(socket, :settings, fn ->
      Settings.get_setting!(socket.assigns.current_scope)
    end)
  end
end
