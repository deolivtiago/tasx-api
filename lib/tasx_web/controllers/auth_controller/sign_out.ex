defmodule TasxWeb.AuthController.SignOut do
  @moduledoc false

  import Ecto.Changeset

  alias TasxCore.Access.Tokens

  @doc false
  def handle(params) do
    params
    |> validate_params()
    |> revoke_tokens()
  end

  defp validate_params(params) do
    types = %{access_token: :string, refresh_token: :string}

    cast({%{}, types}, params, Map.keys(types))
    |> validate_required(Map.keys(types))
    |> apply_action(:validate)
  end

  defp revoke_tokens({:ok, token_pair}) do
    tokens = Map.values(token_pair)

    Tokens.list_tokens()
    |> Enum.filter(&Enum.member?(tokens, &1.token))
    |> Enum.map(&Tokens.revoke_token/1)
    |> Enum.filter(&match?({:ok, _}, &1))
    |> Enum.map(&elem(&1, 1))
  end

  defp revoke_tokens({:error, changeset}), do: {:error, changeset}
end
