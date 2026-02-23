defmodule TasxCore.Access.Tokens.Token.Create do
  @moduledoc false

  import Ecto.Changeset

  alias TasxCore.Access.Tokens.Token
  alias TasxCore.Access.Users.User
  alias TasxCore.JsonWebToken
  alias TasxCore.Repo

  @doc false
  def call(%User{} = user) do
    with {:ok, access_token} <- call(user, :access),
         {:ok, refresh_token} <- call(user, :refresh) do
      {:ok, %{access_token: access_token, refresh_token: refresh_token}}
    end
  end

  def call(%User{id: id}, token_type) when is_atom(token_type) do
    changeset = changeset(id, token_type)

    with {:ok, token} <- Repo.insert(changeset) do
      token
      |> Repo.preload(user: :role)
      |> then(&{:ok, &1})
    end
  end

  defp changeset(sub, typ) do
    payload =
      Map.new()
      |> Map.put(:sub, sub)
      |> Map.put(:typ, typ)

    case JsonWebToken.from_payload(payload) do
      {:ok, jwt} ->
        Token.changeset(jwt)

      {:error, _changeset} ->
        %Token{}
        |> change(%{type: typ, user_id: sub})
        |> add_error(:token, "can't be signed")
    end
  end
end
