defmodule Billing.AuthInvoiceWorkerWorker do
  use Oban.Worker, queue: :default, max_attempts: 1

  alias Billing.ElectronicInvoices
  alias Billing.ElectronicInvoiceCheckerWorker

  require Logger

  @impl Oban.Worker
  def perform(%Oban.Job{args: _args}) do
    electronic_invoices = ElectronicInvoices.list_pending_electronic_invoices()

    Logger.info("Verificando autorización de : #{Enum.count(electronic_invoices)} elementos")

    Enum.each(electronic_invoices, fn ei ->
      %{"electronic_invoice_id" => ei.id}
      |> ElectronicInvoiceCheckerWorker.new()
      |> Oban.insert()
    end)

    :ok
  end
end
