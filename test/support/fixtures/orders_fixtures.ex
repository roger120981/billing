defmodule Billing.OrdersFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Billing.Orders` context.
  """

  @doc """
  Generate a order.
  """
  def order_fixture(attrs \\ %{}) do
    {:ok, order} =
      attrs
      |> Enum.into(%{
        full_name: "some full_name",
        phone_number: "some phone_number",
        items: [
          %{name: "Product", price: Decimal.new("5.00")}
        ]
      })
      |> Billing.Orders.create_order()

    order
  end
end
