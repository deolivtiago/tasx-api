defmodule TasxCore.Access.Users.User.Confirm do
  @moduledoc false

  import Ecto.Changeset

  alias TasxCore.Access.Users.User
  alias TasxCore.Repo

  @doc false
  def call(%User{} = user, code, attrs) when is_binary(code) and is_map(attrs) do
    if User.valid_verification_code?(user, code) do
      user
      |> User.changeset(attrs)
      |> Repo.update()
      |> preload_role()
    else
      {user, %{code: :string}}
      |> change(%{code: code})
      |> add_error(:code, "is invalid")
      |> then(&{:error, &1})
    end
  end

  defp preload_role({:ok, user}) do
    user
    |> Repo.preload(:role)
    |> then(&{:ok, &1})
  end

  defp preload_role(error), do: error
end
