defmodule Billing.Quotes.QuoteItem do
  use Ecto.Schema
  import Ecto.Changeset

  alias Billing.Quotes.Quote

  schema "quote_items" do
    belongs_to :quote, Quote

    field :name, :string
    field :amount, :decimal

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(quote_item, attrs) do
    quote_item
    |> cast(attrs, [:name, :amount])
    |> validate_required([:name, :amount])
  end
end
