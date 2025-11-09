defmodule Billing.Repo.Migrations.AddQuantityToQuoteItem do
  use Ecto.Migration

  def change do
    alter table(:quote_items) do
      add :price, :decimal, precision: 10, scale: 2
      add :quantity, :decimal, precision: 10, scale: 2, default: 1.0
    end
  end
end
