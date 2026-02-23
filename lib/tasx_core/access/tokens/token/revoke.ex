defmodule TasxCore.Access.Tokens.Token.Revoke do
  @moduledoc false

  alias TasxCore.Access.Tokens.Token
  alias TasxCore.Repo

  @doc false
  def call(%Token{} = token) do
    with {:ok, token} <- Repo.delete(token) do
      token
      |> Repo.preload(user: :role)
      |> then(&{:ok, &1})
    end
  end
end
