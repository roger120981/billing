defmodule Billing.Certificates.Certificate do
  use Ecto.Schema
  import Ecto.Changeset

  schema "certificates" do
    field :file, :string
    field :password, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(certificate, attrs) do
    certificate
    |> cast(attrs, [:file, :password])
    |> validate_required([:file, :password])
  end
end
