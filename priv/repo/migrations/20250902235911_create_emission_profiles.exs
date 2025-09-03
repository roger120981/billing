defmodule Billing.Repo.Migrations.CreateEmissionProfiles do
  use Ecto.Migration

  def change do
    create table(:emission_profiles) do
      add :company_id, references(:companies, on_delete: :delete_all)
      add :certificate_id, references(:certificates, on_delete: :delete_all)
      add :name, :string

      timestamps(type: :utc_datetime)
    end

    create index(:emission_profiles, [:company_id])
    create index(:emission_profiles, [:certificate_id])
  end
end
