defmodule Billing.Invoices.ElectronicInvoice do
  use Ecto.Schema
  import Ecto.Changeset

  @statuses [
    :created,
    :signed,
    :sent,
    :back,
    :authorized,
    :unauthorized,
    :error,
    :not_found_or_pending
  ]

  @sri_statuses %{
    "RECIBIDA" => :sent,
    "DEVUELTA" => :back,
    "AUTORIZADO" => :authorized,
    "NO AUTORIZADO" => :unauthorized,
    "ERROR" => :error,
    "NO ENCONTRADO O PENDIENTE" => :not_found_or_pending
  }

  schema "electronic_invoices" do
    belongs_to :invoice, Billing.Invoices.Invoice

    field :access_key, :string
    field :state, Ecto.Enum, values: @statuses, default: :created

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

  def determinate_status(sri_status) do
    @sri_statuses[sri_status]
  end
end
