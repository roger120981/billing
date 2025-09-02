defmodule Billing.CertificatesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Billing.Certificates` context.
  """

  @doc """
  Generate a certificate.
  """
  def certificate_fixture(attrs \\ %{}) do
    {:ok, certificate} =
      attrs
      |> Enum.into(%{
        file: "some file",
        password: "some password"
      })
      |> Billing.Certificates.create_certificate()

    certificate
  end
end
