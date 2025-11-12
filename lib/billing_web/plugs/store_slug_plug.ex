defmodule BillingWeb.Plugs.StoreSlugPlug do
  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _opts) do
    case String.split(conn.host, ".") do
      [subdomain, _domain, _tld] ->
        assign(conn, :store_slug, subdomain)

      _ ->
        conn
    end
  end
end

