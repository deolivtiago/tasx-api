defmodule TasxCore.Access.Tokens.Token.Verify do
  @moduledoc false

  import Ecto.Changeset
  import Ecto.Query, only: [from: 2]

  alias TasxCore.Access.Tokens.Token
  alias TasxCore.JsonWebToken
  alias TasxCore.Repo

  @doc false
  def call(token, token_type) when is_atom(token_type) do
    with {:ok, %{claims: %{typ: ^token_type}}} <- JsonWebToken.from_token(token),
         %Token{} = token <- Repo.get_by(query(), token: token, type: token_type) do
      token
      |> Repo.preload(user: :role)
      |> then(&{:ok, &1})
    else
      _error ->
        %Token{}
        |> change(%{token: token})
        |> add_error(:token, "is invalid")
        |> then(&{:error, &1})
    end
  end

  defp query do
    from ut in Token,
      where: ut.expires_at > ^DateTime.utc_now()
  end
end
