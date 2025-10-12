defmodule Billing.CertificatesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Billing.Certificates` context.
  """

  alias Billing.Certificates

  @doc """
  Generate a certificate.
  """
  def certificate_fixture(attrs \\ %{}) do
    {:ok, certificate} =
      attrs
      |> Enum.into(%{
        name: "My P12 file",
        file: "file.p12",
        password: "fake-password"
      })
      |> Billing.Certificates.create_certificate()

    {:ok, certificate} =
      Certificates.update_certificate_password(certificate, "fake-password")

    certificate
  end
end
