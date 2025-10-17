defmodule Billing.CartsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Billing.Carts` context.
  """

  @doc """
  Generate a cart.
  """

  import Billing.ProductsFixtures

  def cart_fixture(attrs \\ %{}) do
    product = product_fixture()

    {:ok, cart} =
      attrs
      |> Enum.into(%{
        cart_uuid: Ecto.UUID.generate(),
        product_id: product.id
      })
      |> Billing.Carts.create_cart()

    cart
  end
end
