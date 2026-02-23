defmodule TasxWeb.AuthJSON do
  @moduledoc false

  alias TasxCore.Access.Users.User

  @doc """
  Renders a list of users
  """
  def index(%{users: users}), do: %{data: for(user <- users, do: data(user))}

  @doc """
  Renders an user or tokens
  """
  def show(%{user: user}), do: %{data: data(user)}

  def show(%{tokens: tokens}), do: %{data: tokens}

  defp data(%User{} = user) do
    %{
      id: user.id,
      full_name: user.full_name,
      email: user.email,
      avatar_url: user.avatar_url,
      role_id: user.role_id,
      is_verified: user.verified?
    }
  end
end
