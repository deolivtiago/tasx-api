defmodule TasxCore.Access.Users.User.Get do
  @moduledoc false

  import Ecto.Changeset

  alias TasxCore.Access.Users.User
  alias TasxCore.Repo

  @doc false
  def call(key, value, opts \\ [])

  def call(key, value, verified?: true) do
    with {:ok, %User{verified?: false} = user} <- call(key, value) do
      user
      |> change()
      |> add_error(:email, "must be verified")
      |> then(&{:error, &1})
    end
  end

  def call(key, value, _opts) when key in ~w(id email)a when is_binary(value) do
    case Repo.get_by(User, [{key, value}]) do
      %User{} = user ->
        user
        |> Repo.preload(:role)
        |> then(&{:ok, &1})

      nil ->
        %User{}
        |> change()
        |> add_error(key, "not found")
        |> then(&{:error, &1})
    end
  end
end
