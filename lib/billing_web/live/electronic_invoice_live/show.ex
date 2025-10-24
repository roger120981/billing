defmodule BillingWeb.ElectronicInvoiceLive.Show do
  use BillingWeb, :live_view

  alias Billing.ElectronicInvoices
  alias Billing.ElectronicInvoice
  alias Billing.Invoices.ElectronicInvoice
  alias Phoenix.PubSub
  alias Billing.InvoiceHandler
  alias Billing.ElectronicInvoiceErrors
  alias Phoenix.LiveView.AsyncResult

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        Electronic Invoice {@electronic_invoice.id}
        <:subtitle>This is a electronic invoice record from your database.</:subtitle>
        <:actions>
          <.button navigate={~p"/electronic_invoices"}>
            <.icon name="hero-arrow-left" />
          </.button>

          <.send_electronic_invoice_button send_result={@send_result} />
        </:actions>
      </.header>

      <.electronic_invoice_errors errors={@electronic_invoice_errors} />

      <.list>
        <:item title="Status">
          <.electronic_state electronic_invoice={@electronic_invoice} />
        </:item>
        <:item title="Access Key">{@electronic_invoice.access_key}</:item>
        <:item title="Invoice">
          <.link navigate={~p"/invoices/#{@electronic_invoice.invoice_id}"} class="link">
            {@electronic_invoice.invoice_id}
          </.link>
        </:item>
      </.list>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    PubSub.subscribe(Billing.PubSub, "electronic_invoice:#{id}")

    {:ok,
     socket
     |> assign(:page_title, "Show Electronic Invoice")
     |> assign(:send_result, %AsyncResult{})
     |> assign_electronic_invoice(id)}
  end

  @impl true
  def handle_event("send_electronic_invoice", _params, socket) do
    electronic_invoice_id = socket.assigns.electronic_invoice.id

    {:noreply,
     socket
     |> assign(:send_result, AsyncResult.loading())
     |> start_async(:send_electronic_invoice, fn ->
       InvoiceHandler.send_electronic_invoice(electronic_invoice_id)
     end)}
  end

  @impl true
  def handle_async(:send_electronic_invoice, {:ok, {:ok, electronic_invoice}}, socket) do
    {:noreply,
     socket
     |> assign(:send_result, AsyncResult.ok(%AsyncResult{}))
     |> assign_electronic_invoice(electronic_invoice.id)
     |> put_flash(:info, "Electronic sent")}
  end

  def handle_async(:send_electronic_invoice, {:ok, {:error, error}}, socket) do
    {:noreply,
     socket
     |> assign(:send_result, AsyncResult.failed(%AsyncResult{}, {:error, error}))
     |> put_flash(:error, "Error: #{inspect(error)}")}
  end

  def handle_async(:send_electronic_invoice, {:exit, reason}, socket) do
    {:noreply,
     socket
     |> assign(:send_result, AsyncResult.failed(%AsyncResult{}, {:exit, reason}))
     |> put_flash(:error, "Error: #{inspect(reason)}")}
  end

  # @impl true
  # def handle_event("check_electronic_invoice", _params, socket) do
  #   InvoiceHandler.run_authorization_checker(socket.assigns.electronic_invoice.id)
  #
  #   {:noreply, put_flash(socket, :info, "Verifición en proceso")}
  # end
  #
  # @impl true
  # def handle_info(
  #       {:update_electronic_invoice, %{electronic_invoice_id: electronic_invoice_id}},
  #       socket
  #     ) do
  #   {:noreply, assign_electronic_invoice(socket, electronic_invoice_id)}
  # end
  #
  # @impl true
  # def handle_info(
  #       {:electronic_invoice_error,
  #        %{electronic_invoice_id: electronic_invoice_id, error: error}},
  #       socket
  #     ) do
  #   {:noreply,
  #    socket
  #    |> assign_electronic_invoice(electronic_invoice_id)
  #    |> put_flash(:error, "Error en la facturación: #{error}")}
  # end

  attr :electronic_invoice, ElectronicInvoice, default: nil

  defp electronic_state(assigns) do
    assigns =
      assign_new(assigns, :state, fn ->
        if assigns.electronic_invoice do
          %{
            label: ElectronicInvoice.label_status(assigns.electronic_invoice.state),
            css_class: "badge-primary"
          }
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

  attr :errors, :list, default: []

  defp electronic_invoice_errors(%{errors: []} = assigns) do
    ~H"""
    """
  end

  defp electronic_invoice_errors(assigns) do
    ~H"""
    <div role="alert" class="alert alert-error">
      <.icon name="hero-x-circle" />

      <ul>
        <li :for={{key, value} <- @errors}>
          {key}: {value}
        </li>
      </ul>
    </div>
    """
  end

  defp assign_electronic_invoice(socket, electronic_invoice_id) do
    electronic_invoice =
      ElectronicInvoices.get_electronic_invoice!(electronic_invoice_id)

    electronic_invoice_errors = ElectronicInvoiceErrors.list_errors(electronic_invoice)

    socket
    |> assign(:electronic_invoice, electronic_invoice)
    |> assign(:electronic_invoice_errors, electronic_invoice_errors)
  end

  attr :send_result, AsyncResult, required: true

  defp send_electronic_invoice_button(assigns) do
    ~H"""
    <.button variant="primary" phx-click="send_electronic_invoice" disabled={@send_result.loading}>
      <span :if={@send_result.loading} class="loading loading-spinner loading-md"></span>
      <.icon :if={!@send_result.loading} name="hero-paper-airplane" /> Send electronic invoice
    </.button>
    """
  end
end
