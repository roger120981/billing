defmodule Billing.Repo.Migrations.AddEncryptedPasswordToCertificates do
  use Ecto.Migration

  def change do
    alter table(:certificates) do
      add :encrypted_password, :string
      remove :password
    end
  end
end
