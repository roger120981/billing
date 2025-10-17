defmodule Billing.CartsTest do
  use Billing.DataCase

  import Billing.ProductsFixtures

  alias Billing.Carts
  alias Billing.Cart
  alias Repo

  setup do
    product = product_fixture()

    {:ok, product: product}
  end

  describe "carts" do
    alias Billing.Carts.Cart

    import Billing.CartsFixtures

    @invalid_attrs %{cart_uuid: nil, product_id: nil}

    test "list_carts/0 returns all carts" do
      _cart = cart_fixture()
      carts = Repo.all(Cart) |> Repo.preload(:product)

      assert Carts.list_carts() == carts
    end

    test "get_cart!/1 returns the cart with given id" do
      cart = cart_fixture()
      assert Carts.get_cart!(cart.id) == cart
    end

    test "create_cart/1 with valid data creates a cart", %{product: product} do
      valid_attrs = %{cart_uuid: "7488a646-e31f-11e4-aace-600308960662", product_id: product.id}

      assert {:ok, %Cart{} = cart} = Carts.create_cart(valid_attrs)
      assert cart.cart_uuid == "7488a646-e31f-11e4-aace-600308960662"
      assert cart.product_id == product.id
    end

    test "create_cart/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Carts.create_cart(@invalid_attrs)
    end

    test "update_cart/2 with valid data updates the cart", %{product: product} do
      cart = cart_fixture()
      update_attrs = %{cart_uuid: "7488a646-e31f-11e4-aace-600308960668", product_id: product.id}

      assert {:ok, %Cart{} = cart} = Carts.update_cart(cart, update_attrs)
      assert cart.cart_uuid == "7488a646-e31f-11e4-aace-600308960668"
      assert cart.product_id == product.id
    end

    test "update_cart/2 with invalid data returns error changeset" do
      cart = cart_fixture()
      assert {:error, %Ecto.Changeset{}} = Carts.update_cart(cart, @invalid_attrs)
      assert cart == Carts.get_cart!(cart.id)
    end

    test "delete_cart/1 deletes the cart" do
      cart = cart_fixture()
      assert {:ok, %Cart{}} = Carts.delete_cart(cart)
      assert_raise Ecto.NoResultsError, fn -> Carts.get_cart!(cart.id) end
    end

    test "change_cart/1 returns a cart changeset" do
      cart = cart_fixture()
      assert %Ecto.Changeset{} = Carts.change_cart(cart)
    end
  end
end
