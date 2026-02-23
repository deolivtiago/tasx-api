defmodule TasxCore.Access.Tokens do
  @moduledoc """
  `Access.Tokens` context
  """

  alias TasxCore.Access.Tokens.Token

  @doc ~S"""
  Lists all `Token`s

  ## Examples

      iex> list_tokens()
      [%Token{}, ...]

  """
  defdelegate list_tokens, to: Token.List, as: :call

  @doc ~S"""
  Creates a pair of `Token`s

  ## Examples

      iex> create_token_pair(user)
      {:ok, %{access_token: %Token{}, refresh_token: %Token{}}}

      iex> create_token_pair(bad_user)
      {:error, %Ecto.Changeset{}}

  """
  defdelegate create_token_pair(user), to: Token.Create, as: :call

  @doc ~S"""
  Creates an `Token`

  ## Examples

      iex> create_token(user, token_type)
      {:ok, %Token{}}

      iex> create_token(bad_user, token_type)
      {:error, %Ecto.Changeset{}}

  """
  defdelegate create_token(user, token_type), to: Token.Create, as: :call

  @doc ~S"""
  Verifies an `Token`

  ## Examples

      iex> verify_token(token, token_type)
      {:ok, %Token{}}

      iex> verify_token(bad_token, token_type)
      {:error, %Ecto.Changeset{}}

  """
  defdelegate verify_token(token, token_type), to: Token.Verify, as: :call

  @doc ~S"""
  Revokes an `Token`

  ## Examples

      iex> revoke_token(token)
      {:ok, %Token{}}

      iex> revoke_token(invalid_token)
      {:error, %Ecto.Changeset{}}

  """
  defdelegate revoke_token(token), to: Token.Revoke, as: :call
end
