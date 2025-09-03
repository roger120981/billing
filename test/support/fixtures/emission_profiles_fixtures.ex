defmodule Billing.EmissionProfilesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Billing.EmissionProfiles` context.
  """

  @doc """
  Generate a emission_profile.
  """
  def emission_profile_fixture(attrs \\ %{}) do
    {:ok, emission_profile} =
      attrs
      |> Enum.into(%{
        name: "some name"
      })
      |> Billing.EmissionProfiles.create_emission_profile()

    emission_profile
  end
end
