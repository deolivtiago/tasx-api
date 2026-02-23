defmodule TasxCore.Access.Users.User.Update do
  @moduledoc false

  alias TasxCore.Access.Users.User
  alias TasxCore.Repo

  @doc false
  def call(%User{} = user, attrs) when is_map(attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
    |> preload_role()
  end

  defp preload_role({:ok, user}) do
    user
    |> Repo.preload(:role)
    |> then(&{:ok, &1})
  end

  defp preload_role(error), do: error
end
