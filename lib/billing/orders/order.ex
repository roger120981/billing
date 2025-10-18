defmodule Billing.Orders.Order do
  use Ecto.Schema
  import Ecto.Changeset

  schema "orders" do
    field :full_name, :string
    field :phone_number, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(order, attrs) do
    order
    |> cast(attrs, [:full_name, :phone_number])
    |> validate_required([:full_name, :phone_number])
  end
end
