defmodule TasxCore.Access.RoleFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `TasxCore.Access.Roles` context.
  """

  alias TasxCore.Access.Roles.Role
  alias TasxCore.Repo

  @doc """
  Generate fake `Role` attrs

  ## Examples

      iex> role_attrs(%{field: value})
      %{field: value, ...}

  """
  def role_attrs(attrs \\ %{}) do
    id = Faker.Person.title() |> String.replace(~r/.+\s|[^a-zA-Z0-9_]/, "")

    Map.new()
    |> Map.put(:id, id)
    |> Map.put(:permissions, ["GET:api/auth/user-info"])
    |> Map.put(:inserted_at, DateTime.add(DateTime.utc_now(), Enum.random(-90..-1), :day))
    |> Map.put(:updated_at, DateTime.add(DateTime.utc_now(), Enum.random(-90..-1), :day))
    |> Map.merge(attrs)
  end

  @doc """
  Builds a fake `Role`

    ## Examples

      iex> build_role(attrs)
      %Role{field: value, ...}

  """
  def build_role(attrs \\ %{}) do
    attrs
    |> role_attrs()
    |> Role.changeset()
    |> Ecto.Changeset.apply_action!(nil)
  end

  @doc """
  Inserts a fake `Role`

    ## Examples

      iex> insert_role(attrs)
      %Role{field: value, ...}

  """
  def insert_role(attrs \\ %{}) do
    attrs
    |> role_attrs()
    |> Role.changeset()
    |> Repo.insert!()
  end

  @doc """
  deletes all `Role`s

    ## Examples

      iex> delete_roles()
      []

  """
  def delete_roles do
    with {_, nil} <- Repo.delete_all(Role), do: []
  end
end
