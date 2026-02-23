defmodule TasxWeb.AuthController.RefreshToken do
  @moduledoc false

  import Ecto.Changeset

  alias TasxCore.Access.Tokens

  @doc false
  def handle(params) do
    params
    |> validate_params()
    |> verify_token()
    |> create_tokens()
  end

  defp validate_params(params) do
    types = %{token: :string}

    cast({%{}, types}, params, Map.keys(types))
    |> validate_required(Map.keys(types))
    |> apply_action(:validate)
  end

  defp verify_token({:ok, %{token: token}}), do: Tokens.verify_token(token, :refresh)
  defp verify_token({:error, changeset}), do: {:error, changeset}

  defp create_tokens({:ok, token}) do
    with {:ok, access_token} <- Tokens.create_token(token.user, :access),
         {:ok, refresh_token} <- Tokens.create_token(token.user, :refresh) do
      Tokens.revoke_token(token)

      Map.new()
      |> Map.put(:access_token, access_token.token)
      |> Map.put(:refresh_token, refresh_token.token)
      |> then(&{:ok, &1})
    end
  end

  defp create_tokens({:error, changeset}), do: {:error, changeset}
end
