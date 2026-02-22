defmodule TasxCore.Access.Roles do
  @moduledoc """
  `Access.Roles` context
  """

  alias TasxCore.Access.Roles.Role

  @doc ~S"""
  Lists all `Role`s

  ## Examples

      iex> list_roles()
      [%Role{}, ...]

  """
  defdelegate list_roles, to: Role.List, as: :call

  @doc ~S"""
  Gets a `Role`

  ## Examples

      iex> get_role(field, value)
      {:ok, %Role{}}

      iex> get_role(field, bad_value)
      {:error, %Ecto.Changeset{}}

  """
  defdelegate get_role(field, value), to: Role.Get, as: :call

  @doc ~S"""
  Creates a `Role`

  ## Examples

      iex> create_role(attrs)
      {:ok, %Role{}}

      iex> create_role(bad_attrs)
      {:error, %Ecto.Changeset{}}

  """
  defdelegate create_role(attrs), to: Role.Create, as: :call

  @doc ~S"""
  Updates a `Role`

  ## Examples

      iex> update_role(role, attrs)
      {:ok, %Role{}}

      iex> update_role(role, bad_attrs)
      {:error, %Ecto.Changeset{}}

  """
  defdelegate update_role(role, attrs), to: Role.Update, as: :call

  @doc ~S"""
  Deletes a `Role`

  ## Examples

      iex> delete_role(role)
      {:ok, %Role{}}

      iex> delete_role(bad_role)
      {:error, %Ecto.Changeset{}}

  """
  defdelegate delete_role(role), to: Role.Delete, as: :call
end
