defmodule Billing.ElectronicInvoices do
  @moduledoc false

  import Ecto.Query, warn: false
  alias Billing.Repo

  alias Billing.Invoices.ElectronicInvoice

  def create_electronic_invoice(invoice_id, access_key) do
    attrs = %{invoice_id: invoice_id, access_key: access_key}

    %ElectronicInvoice{}
    |> ElectronicInvoice.changeset(attrs)
    |> Repo.insert()
  end

  def update_electronic_invoice(%ElectronicInvoice{} = electronic_invoice, state) do
    attrs = %{state: state}

    electronic_invoice
    |> ElectronicInvoice.changeset(attrs)
    |> Repo.update()
  end
end
