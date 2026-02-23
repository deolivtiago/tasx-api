defmodule TasxCore.Access.UserFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `TasxCore.Access.Users` context.
  """

  alias TasxCore.Access.Users.User
  alias TasxCore.Repo

  @doc """
  Generate fake `User` attrs.

  ## Examples

      iex> user_attrs(%{field: value})
      %{field: value, ...}

  """
  def user_attrs(attrs \\ %{}) do
    otp_secret = NimbleTOTP.secret()

    Map.new()
    |> Map.put(:id, Ecto.UUID.generate())
    |> Map.put(:full_name, Faker.Person.name())
    |> Map.put(:email, Faker.Internet.email())
    |> Map.put(:password, "P455w0rd?")
    |> Map.put(:avatar_url, Faker.Avatar.image_url())
    |> Map.put(:role_id, "user")
    |> Map.put(:verified?, true)
    |> Map.put(:otp_secret, otp_secret)
    |> Map.put(:inserted_at, DateTime.add(DateTime.utc_now(), Enum.random(-90..-1), :day))
    |> Map.put(:updated_at, DateTime.add(DateTime.utc_now(), Enum.random(-90..-1), :day))
    |> Map.merge(attrs)
  end

  @doc """
  Builds a fake `User`

  ## Examples

      iex> build_user(%{field: value})
      %User{field: value, ...}

  """
  def build_user(attrs \\ %{}) do
    attrs
    |> user_attrs()
    |> User.changeset()
    |> Ecto.Changeset.apply_action!(nil)
  end

  @doc """
  Inserts a fake `User`

  ## Examples

      iex> insert_user(%{field: value})
      %User{field: value, ...}

  """
  def insert_user(attrs \\ %{}) do
    attrs
    |> user_attrs()
    |> User.changeset()
    |> Repo.insert!()
    |> Repo.preload(:role)
  end
end
