defmodule Billing.Repo.Migrations.AddQuantityToOrderItem do
  use Ecto.Migration

  def change do
    alter table(:order_items) do
      add :quantity, :decimal, precision: 10, scale: 2, default: 1.0
      add :amount, :decimal, precision: 10, scale: 2
    end

    alter table(:orders) do
      add :amount, :decimal, precision: 10, scale: 2
    end
  end
end
