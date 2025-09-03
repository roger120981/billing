defmodule Billing.Repo.Migrations.AddNameToCertificates do
  use Ecto.Migration

  def change do
    alter table(:certificates) do
      add :name, :string
    end
  end
end
