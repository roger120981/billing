defmodule Billing.Carts.Cart do
  use Ecto.Schema
  import Ecto.Changeset

  alias Billing.Products.Product

  schema "carts" do
    belongs_to :product, Product

    field :cart_uuid, Ecto.UUID

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(cart, attrs) do
    cart
    |> cast(attrs, [:cart_uuid, :product_id])
    |> validate_required([:cart_uuid, :product_id])
    |> unique_constraint([:cart_uuid, :product_id])
  end
end
