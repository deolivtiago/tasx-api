defmodule TasxCore.Access.Users.User.Create do
  @moduledoc false

  alias TasxCore.Access.Users.User
  alias TasxCore.Repo

  @doc false
  def call(attrs) when is_map(attrs) do
    attrs
    |> User.changeset()
    |> Repo.insert()
    |> preload_role()
  end

  defp preload_role({:ok, user}) do
    user
    |> Repo.preload(:role)
    |> then(&{:ok, &1})
  end

  defp preload_role(error), do: error
end
