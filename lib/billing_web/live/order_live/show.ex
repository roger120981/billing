defmodule BillingWeb.OrderLive.Show do
  use BillingWeb, :live_view

  alias Billing.Orders
  alias Billing.Customers
  alias Billing.Customers.Customer

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        Order {@order.id}
        <:subtitle>This is a order record from your database.</:subtitle>
        <:actions>
          <.button navigate={~p"/orders"}>
            <.icon name="hero-arrow-left" />
          </.button>
          <.button variant="primary" phx-click="create_invoice">
            <.icon name="hero-pencil-square" /> Create Invoice
          </.button>
        </:actions>
      </.header>

      <.list>
        <:item title="Name">{@order.full_name}</:item>
        <:item title="Price">{@order.phone_number}</:item>
      </.list>

      <h2>Items</h2>

      <.table
        id="items"
        rows={@order.items}
      >
        <:col :let={item} label="Name">{item.name}</:col>
        <:col :let={item} label="Price">{item.price}</:col>
      </.table>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Show Order")
     |> assign(:order, Orders.get_order!(id))}
  end

  @impl true
  def handle_event("create_invoice", _params, socket) do
    with {:ok, _customer} <- find_or_create_customer(socket.assigns.order) do
      {:noreply, redirect(socket, to: ~p"/invoices")}
    else
      {:error, error} ->
        {:noreply, put_flash(socket, :error, inspect(error))}
    end
  end

  defp find_or_create_customer(order) do
    order
    |> Map.take(Customer.list_required_fields())
    |> Customers.find_or_create_customer()
  end
end
