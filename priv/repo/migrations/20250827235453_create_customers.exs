defmodule Billing.Repo.Migrations.CreateCustomers do
  use Ecto.Migration

  def change do
    create table(:customers) do
      add :full_name, :string
      add :email, :string
      add :identification_type, :string
      add :identification_number, :string
      add :address, :string
      add :phone_number, :string

      timestamps(type: :utc_datetime)
    end
  end
end
