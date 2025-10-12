defmodule Billing.EmissionProfilesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Billing.EmissionProfiles` context.
  """

  import Billing.CertificatesFixtures
  import Billing.CompaniesFixtures

  @doc """
  Generate a emission_profile.
  """
  def emission_profile_fixture(attrs \\ %{}) do
    certificate = certificate_fixture()
    company = company_fixture()

    {:ok, emission_profile} =
      attrs
      |> Enum.into(%{
        name: "Matrix",
        certificate_id: certificate.id,
        company_id: company.id,
        sequence: 1
      })
      |> Billing.EmissionProfiles.create_emission_profile()

    emission_profile
  end
end
