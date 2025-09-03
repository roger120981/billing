defmodule Billing.Repo.Migrations.AddEmissionProfileIdToInvoices do
  use Ecto.Migration

  def change do
    alter table(:invoices) do
      add :emission_profile_id, references(:emission_profiles, on_delete: :nothing)
    end

    create index(:invoices, [:emission_profile_id])
  end
end
