defmodule TasxCore.Access.Tokens.Token.List do
  @moduledoc false

  alias TasxCore.Access.Tokens.Token
  alias TasxCore.Repo

  @doc false
  def call do
    Token
    |> Repo.all()
    |> Repo.preload(user: :role)
  end
end
