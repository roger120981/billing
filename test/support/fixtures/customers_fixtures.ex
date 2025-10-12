defmodule Billing.CustomersFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Billing.Customers` context.
  """

  @doc """
  Generate a customer.
  """
  def customer_fixture(attrs \\ %{}) do
    {:ok, customer} =
      attrs
      |> Enum.into(%{
        full_name: "Sub Zero",
        email: "sub.zero@example.com",
        identification_number: "1234567890",
        identification_type: :cedula,
        address: "Arena",
        phone_number: "123456789"
      })
      |> Billing.Customers.create_customer()

    customer
  end
end
