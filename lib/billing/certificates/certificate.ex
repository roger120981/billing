defmodule Billing.Certificates.Certificate do
  use Ecto.Schema
  import Ecto.Changeset

  schema "certificates" do
    has_many :emission_profiles, Billing.EmissionProfiles.EmissionProfile

    field :name, :string
    field :file, :string
    field :password, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(certificate, attrs) do
    certificate
    |> cast(attrs, [:name, :file, :password])
    |> validate_required([:name, :file, :password])
  end
end
