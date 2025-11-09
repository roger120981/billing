defmodule Billing.Orders do
  @moduledoc """
  The Orders context.
  """

  import Ecto.Query, warn: false

  alias Billing.Repo
  alias Billing.Orders.Order
  alias Billing.Orders.OrderItem
  alias Ecto.Multi

  @doc """
  Returns the list of orders.

  ## Examples

      iex> list_orders()
      [%Order{}, ...]

  """
  def list_orders do
    Repo.all(Order)
  end

  @doc """
  Gets a single order.

  Raises `Ecto.NoResultsError` if the Order does not exist.

  ## Examples

      iex> get_order!(123)
      %Order{}

      iex> get_order!(456)
      ** (Ecto.NoResultsError)

  """
  def get_order!(id), do: Repo.get!(Order, id) |> Repo.preload(:items)

  @doc """
  Creates a order.

  ## Examples

      iex> create_order(%{field: value})
      {:ok, %Order{}}

      iex> create_order(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_order(attrs) do
    %Order{}
    |> Order.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a order.

  ## Examples

      iex> update_order(order, %{field: new_value})
      {:ok, %Order{}}

      iex> update_order(order, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_order(%Order{} = order, attrs) do
    order
    |> Order.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a order.

  ## Examples

      iex> delete_order(order)
      {:ok, %Order{}}

      iex> delete_order(order)
      {:error, %Ecto.Changeset{}}

  """
  def delete_order(%Order{} = order) do
    Repo.delete(order)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking order changes.

  ## Examples

      iex> change_order(order)
      %Ecto.Changeset{data: %Order{}}

  """
  def change_order(%Order{} = order, attrs \\ %{}) do
    Order.changeset(order, attrs)
  end

  def save_order_amounts(%Order{} = order) do
    query = from oi in OrderItem, where: oi.order_id == ^order.id
    items = Repo.all(query)

    multi =
      Enum.reduce(items, Multi.new(), fn item, acc ->
        amount = Decimal.mult(item.price, item.quantity)

        changeset = Ecto.Changeset.change(item, amount: amount)
        Multi.update(acc, :"update_item_#{item.id}", changeset)
      end)
      |> Multi.run(:calculate_amounts, fn _repo, changes ->
        updated_items =
          Enum.map(items, fn item ->
            case Map.get(changes, :"update_item_#{item.id}") do
              nil -> item
              updated -> updated
            end
          end)

        amount =
          updated_items
          |> Enum.map(& &1.amount)
          |> Enum.reduce(Decimal.new(0), &Decimal.add/2)

        {:ok, amount}
      end)
      |> Multi.update(:update_order, fn %{
                                          calculate_amounts: amount
                                        } ->
        Ecto.Changeset.change(order,
          amount: amount
        )
      end)

    Repo.transaction(multi)
  end
end
