defmodule Billing.StoreScope do
  import Ecto.Query, warn: false

  alias Billing.Repo
  alias Billing.Accounts.User
  alias Billing.Accounts.Scope

  def get_store_scope do
    user =
      User
      |> first()
      |> Repo.one()

    Scope.for_user(user)
  end
end
