defmodule TasxCore.Access.Users do
  @moduledoc """
  `Access.Users` context
  """

  alias TasxCore.Access.Users.User

  @doc ~S"""
  Lists all `User`s

  ## Examples

      iex> list_users()
      [%User{}, ...]

  """
  defdelegate list_users, to: User.List, as: :call

  @doc ~S"""
  Gets an `User`

  ## Examples

      iex> get_user(field, value)
      {:ok, %User{}}

      iex> get_user(field, bad_value)
      {:error, %Ecto.Changeset{}}

  """
  defdelegate get_user(field, value, opts \\ []), to: User.Get, as: :call

  @doc ~S"""
  Creates an `User`

  ## Examples

      iex> create_user(attrs)
      {:ok, %User{}}

      iex> create_user(bad_attrs)
      {:error, %Ecto.Changeset{}}

  """
  defdelegate create_user(attrs), to: User.Create, as: :call

  @doc ~S"""
  Updates an `User`

  ## Examples

      iex> update_user(user, attrs)
      {:ok, %User{}}

      iex> update_user(user, bad_attrs)
      {:error, %Ecto.Changeset{}}

  """
  defdelegate update_user(user, attrs), to: User.Update, as: :call

  @doc ~S"""
  Deletes an `User`

  ## Examples

      iex> delete_user(user)
      {:ok, %User{}}

      iex> delete_user(bad_user)
      {:error, %Ecto.Changeset{}}

  """
  defdelegate delete_user(user), to: User.Delete, as: :call

  @doc ~S"""
  Authenticates an `User`

  ## Examples

      iex> authenticate_user(attrs)
      {:ok, %User{}}

      iex> authenticate_user(bad_attrs)
      {:error, %Ecto.Changeset{}}

  """
  defdelegate authenticate_user(attrs), to: User.Authenticate, as: :call

  @doc ~S"""
  Sends a code to verify an `User`

  ## Examples

      iex> verify_user(user)
      {:ok, %User{}}

      iex> verify_user(user)
      {:error, %Ecto.Changeset{}}

  """
  defdelegate verify_user(user), to: User.Verify, as: :call

  @doc ~S"""
  Confirms an `User` verification

  ## Examples

      iex> confirm_user(user, code, attrs)
      {:ok, %User{}}

      iex> confirm_user(user, bad_code, attrs)
      {:error, %Ecto.Changeset{}}

  """
  defdelegate confirm_user(user, code, attrs \\ %{verified?: true}), to: User.Confirm, as: :call
end
