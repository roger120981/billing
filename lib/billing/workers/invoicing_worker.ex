defmodule Billing.InvoicingWorker do
  use Oban.Worker, queue: :default, max_attempts: 1

  alias Billing.InvoiceHandler

  require Logger

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"invoice_id" => invoice_id} = _args}) do
    case InvoiceHandler.handle_invoice(invoice_id) do
      {:ok, _emission_profile} ->
        Logger.info("Facturado!: #{inspect(invoice_id)}")

        :ok

      {:error, error} ->
        Logger.error("Error en la facturacion: #{inspect(error)}")

        {:error, error}
    end
  end
end
