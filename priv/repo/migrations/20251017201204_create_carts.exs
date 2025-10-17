defmodule Billing.Repo.Migrations.CreateCarts do
  use Ecto.Migration

  def change do
    create table(:carts) do
      add :cart_uuid, :uuid
      add :product_id, references(:products, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end

    create unique_index(:carts, [:cart_uuid, :product_id])
  end
end
