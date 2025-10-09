defmodule Billing.ElectronicInvoiceCheckerWorker do
  use Oban.Worker, queue: :default, max_attempts: 3

  alias Billing.InvoiceHandler

  require Logger

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"electronic_invoice_id" => electronic_invoice_id} = _args}) do
    case InvoiceHandler.handle_auth_invoice(electronic_invoice_id) do
      {:ok, _emission_profile} ->
        Logger.info("Facturado!: #{electronic_invoice_id}")

        :ok

      {:error, error} ->
        Logger.error("No se pudo verificar la autorización de la factura: #{inspect(error)}")

        {:error, error}
    end
  end
end
