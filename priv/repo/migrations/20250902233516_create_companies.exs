defmodule Billing.Repo.Migrations.CreateCompanies do
  use Ecto.Migration

  def change do
    create table(:companies) do
      add :identification_number, :string
      add :address, :string
      add :name, :string

      timestamps(type: :utc_datetime)
    end
  end
end
