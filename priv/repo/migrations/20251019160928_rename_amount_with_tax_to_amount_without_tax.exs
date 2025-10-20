defmodule Billing.Repo.Migrations.RenameAmountWithTaxToAmountWithoutTax do
  use Ecto.Migration

  def change do
    rename table(:invoices), :amount_with_tax, to: :amount_without_tax
  end
end
