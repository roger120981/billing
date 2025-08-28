defmodule Billing.Customers.Customer do
  use Ecto.Schema
  import Ecto.Changeset

  schema "customers" do
    field :full_name, :string
    field :email, :string
    field :identification_number, :string
    field :identification_type, Ecto.Enum, values: [:cedula, :ruc]
    field :address, :string
    field :phone_number, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(customer, attrs) do
    customer
    |> cast(attrs, [
      :full_name,
      :email,
      :identification_number,
      :identification_type,
      :address,
      :phone_number
    ])
    |> validate_required([
      :full_name,
      :email,
      :identification_number,
      :identification_type,
      :address,
      :phone_number
    ])
  end
end
