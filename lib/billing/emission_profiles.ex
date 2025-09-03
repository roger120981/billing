defmodule Billing.EmissionProfiles do
  @moduledoc """
  The EmissionProfiles context.
  """

  import Ecto.Query, warn: false
  alias Billing.Repo

  alias Billing.EmissionProfiles.EmissionProfile

  @doc """
  Returns the list of emission_profiles.

  ## Examples

      iex> list_emission_profiles()
      [%EmissionProfile{}, ...]

  """
  def list_emission_profiles do
    Repo.all(EmissionProfile)
  end

  @doc """
  Gets a single emission_profile.

  Raises `Ecto.NoResultsError` if the Emission profile does not exist.

  ## Examples

      iex> get_emission_profile!(123)
      %EmissionProfile{}

      iex> get_emission_profile!(456)
      ** (Ecto.NoResultsError)

  """
  def get_emission_profile!(id), do: Repo.get!(EmissionProfile, id)

  @doc """
  Creates a emission_profile.

  ## Examples

      iex> create_emission_profile(%{field: value})
      {:ok, %EmissionProfile{}}

      iex> create_emission_profile(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_emission_profile(attrs) do
    %EmissionProfile{}
    |> EmissionProfile.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a emission_profile.

  ## Examples

      iex> update_emission_profile(emission_profile, %{field: new_value})
      {:ok, %EmissionProfile{}}

      iex> update_emission_profile(emission_profile, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_emission_profile(%EmissionProfile{} = emission_profile, attrs) do
    emission_profile
    |> EmissionProfile.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a emission_profile.

  ## Examples

      iex> delete_emission_profile(emission_profile)
      {:ok, %EmissionProfile{}}

      iex> delete_emission_profile(emission_profile)
      {:error, %Ecto.Changeset{}}

  """
  def delete_emission_profile(%EmissionProfile{} = emission_profile) do
    Repo.delete(emission_profile)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking emission_profile changes.

  ## Examples

      iex> change_emission_profile(emission_profile)
      %Ecto.Changeset{data: %EmissionProfile{}}

  """
  def change_emission_profile(%EmissionProfile{} = emission_profile, attrs \\ %{}) do
    EmissionProfile.changeset(emission_profile, attrs)
  end
end
