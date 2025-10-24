defmodule BillingWeb.InvoiceLive.Show do
  use BillingWeb, :live_view

  alias Billing.Invoices
  # alias Billing.InvoicingWorker
  alias Phoenix.PubSub
  alias Billing.InvoiceHandler
  alias Phoenix.LiveView.AsyncResult

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
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

          <.sign_electronic_invoice_button sign_result={@sign_result} />
        </:actions>
      </.header>

      <.list>
        <:item title="Issued at">{@invoice.issued_at}</:item>
        <:item title="Customer">{@invoice.customer.full_name}</:item>
      </.list>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    PubSub.subscribe(Billing.PubSub, "invoice:#{id}")

    {:ok,
     socket
     |> assign(:page_title, "Show Invoice")
     |> assign(:invoice, Invoices.get_invoice!(id))
     |> assign(:sign_result, %AsyncResult{})}
  end

  @impl true
  def handle_event("sign_electronic_invoice", _params, socket) do
    invoice_id = socket.assigns.invoice.id

    {:noreply,
     socket
     |> assign(:sign_result, AsyncResult.loading())
     |> start_async(:sign_electronic_invoice, fn ->
       InvoiceHandler.sign_electronic_invoice(invoice_id)
     end)}
  end

  @impl true
  def handle_async(:sign_electronic_invoice, {:ok, {:ok, electronic_invoice}}, socket) do
    # %{"electronic_invoice_id" => electronic_invoice.id}
    # |> InvoicingWorker.new()
    # |> Oban.insert()

    {:noreply,
     socket
     |> assign(:sign_result, AsyncResult.ok(electronic_invoice))
     |> put_flash(:info, "Electronic invoice signed")}
  end

  def handle_async(:sign_electronic_invoice, {:ok, {:error, error}}, socket) do
    {:noreply,
     socket
     |> assign(:sign_result, AsyncResult.failed(%AsyncResult{}, {:error, error}))
     |> put_flash(:error, "Error: #{inspect(error)}")}
  end

  def handle_async(:sign_electronic_invoice, {:exit, reason}, socket) do
    {:noreply,
     socket
     |> assign(:sign_result, AsyncResult.failed(%AsyncResult{}, {:exit, reason}))
     |> put_flash(:error, "Error: #{inspect(reason)}")}
  end

  attr :sign_result, AsyncResult, required: true

  defp sign_electronic_invoice_button(assigns) do
    ~H"""
    <.button variant="primary" phx-click="sign_electronic_invoice" disabled={@sign_result.loading}>
      <span :if={@sign_result.loading} class="loading loading-spinner loading-md"></span>
      <.icon :if={!@sign_result.loading} name="hero-finger-print" /> Sign electronic invoice
    </.button>
    """
  end
end
