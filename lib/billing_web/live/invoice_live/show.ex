defmodule BillingWeb.InvoiceLive.Show do
  use BillingWeb, :live_view

  alias Billing.Invoices
  alias Billing.ElectronicInvoices
  alias Billing.Invoices.ElectronicInvoice
  alias Billing.InvoicingWorker

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        Invoice {@invoice.id}
        <:subtitle>This is a invoice record from your database.</:subtitle>
        <:actions>
          <.button navigate={~p"/invoices"}>
            <.icon name="hero-arrow-left" />
          </.button>
          <.button variant="primary" navigate={~p"/invoices/#{@invoice}/edit?return_to=show"}>
            <.icon name="hero-pencil-square" /> Edit invoice
          </.button>
          <.button phx-click="sign_xml">
            <.icon name="hero-pencil-square" /> Crear Factura
          </.button>
        </:actions>
      </.header>

      <.list>
        <:item title="Status">
          <.electronic_state electronic_invoice={@electronic_invoice} />
        </:item>
        <:item title="Issued at">{@invoice.issued_at}</:item>
        <:item title="Customer">{@invoice.customer.full_name}</:item>
      </.list>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Show Invoice")
     |> assign(:invoice, Invoices.get_invoice!(id))
     |> assign(:electronic_invoice, ElectronicInvoices.get_electronic_invoice_by_invoice_id(id))}
  end

  @impl true
  def handle_event("sign_xml", _params, socket) do
    %{"invoice_id" => socket.assigns.invoice.id}
    |> InvoicingWorker.new()
    |> Oban.insert()

    {:noreply, put_flash(socket, :info, "Facturacion en proceso")}
  end

  attr :electronic_invoice, ElectronicInvoice, default: nil

  defp electronic_state(assigns) do
    assigns = assign_new(assigns, :state, fn ->
      if assigns.electronic_invoice do
        %{label: assigns.electronic_invoice.state, css_class: "badge-primary"}
      else
        %{label: "Not invoice yet", css_class: "badge-info"}
      end
    end)


    ~H"""
    <span class={["badge", @state.css_class]}>
      {@state.label}
    </span>
    """
  end
end
