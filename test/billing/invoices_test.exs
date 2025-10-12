defmodule Billing.InvoicesTest do
  use Billing.DataCase

  import Billing.CustomersFixtures
  import Billing.EmissionProfilesFixtures

  alias Billing.Invoices
  alias Billing.Repo
  alias Billing.Invoices.Invoice

  setup do
    customer = customer_fixture()
    emission_profile = emission_profile_fixture()

    {:ok, customer: customer, emission_profile: emission_profile}
  end

  describe "invoices" do
    alias Billing.Invoices.Invoice

    import Billing.InvoicesFixtures

    @invalid_attrs %{issued_at: nil}

    test "list_invoices/0 returns all invoices" do
      invoice = invoice_fixture()

      invoice =
        Invoice
        |> Repo.get!(invoice.id)
        |> Repo.preload([:customer])

      assert Invoices.list_invoices() == [invoice]
    end

    test "get_invoice!/1 returns the invoice with given id" do
      invoice = invoice_fixture()

      invoice =
        Invoice
        |> Repo.get!(invoice.id)
        |> Repo.preload([:customer])

      assert Invoices.get_invoice!(invoice.id) == invoice
    end

    test "create_invoice/1 with valid data creates a invoice", %{
      customer: customer,
      emission_profile: emission_profile
    } do
      valid_attrs = %{
        customer_id: customer.id,
        emission_profile_id: emission_profile.id,
        issued_at: ~D[2025-08-28],
        description: "Invoice Test",
        due_date: ~D[2025-08-28],
        amount: Decimal.new("10.0"),
        tax_rate: Decimal.new("15.0"),
        payment_method: :cash
      }

      assert {:ok, %Invoice{} = invoice} = Invoices.create_invoice(valid_attrs)
      assert invoice.issued_at == ~D[2025-08-28]
    end

    test "create_invoice/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Invoices.create_invoice(@invalid_attrs)
    end

    test "update_invoice/2 with valid data updates the invoice" do
      invoice = invoice_fixture()
      update_attrs = %{issued_at: ~D[2025-08-29]}

      assert {:ok, %Invoice{} = invoice} = Invoices.update_invoice(invoice, update_attrs)
      assert invoice.issued_at == ~D[2025-08-29]
    end

    test "update_invoice/2 with invalid data returns error changeset" do
      invoice = invoice_fixture()

      invoice =
        Invoice
        |> Repo.get!(invoice.id)
        |> Repo.preload([:customer])

      assert {:error, %Ecto.Changeset{}} = Invoices.update_invoice(invoice, @invalid_attrs)
      assert invoice == Invoices.get_invoice!(invoice.id)
    end

    test "delete_invoice/1 deletes the invoice" do
      invoice = invoice_fixture()
      assert {:ok, %Invoice{}} = Invoices.delete_invoice(invoice)
      assert_raise Ecto.NoResultsError, fn -> Invoices.get_invoice!(invoice.id) end
    end

    test "change_invoice/1 returns a invoice changeset" do
      invoice = invoice_fixture()
      assert %Ecto.Changeset{} = Invoices.change_invoice(invoice)
    end
  end
end
