defmodule Billing.Invoices.ElectronicInvoice do
  use Ecto.Schema
  import Ecto.Changeset

  schema "electronic_invoices" do
    belongs_to :invoice, Billing.Invoices.Invoice

    field :access_key, :string
    field :state, Ecto.Enum, values: [:created, :signed, :sent, :auth, :unauth, :error], default: :created

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(electronic_invoice, attrs) do
    electronic_invoice
    |> cast(attrs, [
      :invoice_id,
      :access_key,
      :state
    ])
    |> validate_required([
      :invoice_id,
      :access_key,
      :state
    ])
  end
end
