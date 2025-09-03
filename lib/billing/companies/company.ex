defmodule Billing.Companies.Company do
  use Ecto.Schema
  import Ecto.Changeset

  schema "companies" do
    field :identification_number, :string
    field :address, :string
    field :name, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(company, attrs) do
    company
    |> cast(attrs, [:identification_number, :address, :name])
    |> validate_required([:identification_number, :address, :name])
  end
end
