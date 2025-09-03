defmodule Billing.CompaniesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Billing.Companies` context.
  """

  @doc """
  Generate a company.
  """
  def company_fixture(attrs \\ %{}) do
    {:ok, company} =
      attrs
      |> Enum.into(%{
        address: "some address",
        identification_number: "some identification_number",
        name: "some name"
      })
      |> Billing.Companies.create_company()

    company
  end
end
