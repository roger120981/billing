defmodule Billing.Repo.Migrations.CreateCertificates do
  use Ecto.Migration

  def change do
    create table(:certificates) do
      add :file, :string
      add :password, :string

      timestamps(type: :utc_datetime)
    end
  end
end
