defmodule TasxCore.Access.TokenFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `TasxCore.Access.Tokens` context.
  """
  import TasxCore.JsonWebTokenFixtures

  alias TasxCore.Access.Tokens.Token
  alias TasxCore.Access.Users.User
  alias TasxCore.Repo

  @doc """
  Builds a fake `Token`

  ## Examples

      iex> build_token(user, opts)
      %Token{field: value, ...}

  """
  def build_token(%User{} = user, opts \\ []) do
    user
    |> build_jwt(opts)
    |> Token.changeset()
    |> Ecto.Changeset.apply_action!(nil)
  end

  @doc """
  Inserts a fake `Token`

  ## Examples

      iex> insert_token(user, opts)
      %Token{field: value, ...}

  """
  def insert_token(%User{} = user, opts \\ []) do
    user
    |> build_jwt(opts)
    |> Token.changeset()
    |> Repo.insert!()
    |> Repo.preload(user: :role)
  end
end
