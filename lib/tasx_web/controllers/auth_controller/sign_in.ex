defmodule TasxWeb.AuthController.SignIn do
  @moduledoc false

  import Ecto.Changeset

  alias TasxCore.Access.Tokens
  alias TasxCore.Access.Users

  @doc false
  def handle(params) do
    params
    |> validate_params()
    |> authenticate_user()
    |> create_tokens()
  end

  defp validate_params(params) do
    types = %{email: :string, password: :string}

    cast({%{}, types}, params, Map.keys(types))
    |> validate_required(Map.keys(types))
    |> update_change(:email, &String.downcase/1)
    |> validate_format(:email, ~r/^[a-z0-9._%+-]+@[a-z0-9.-]+\.[a-z]{2,}$/)
    |> apply_action(:validate)
  end

  defp authenticate_user({:ok, user_attrs}), do: Users.authenticate_user(user_attrs)
  defp authenticate_user({:error, changeset}), do: {:error, changeset}

  defp create_tokens({:ok, user}) do
    with {:ok, access_token} <- Tokens.create_token(user, :access),
         {:ok, refresh_token} <- Tokens.create_token(user, :refresh) do
      Map.new()
      |> Map.put(:access_token, access_token.token)
      |> Map.put(:refresh_token, refresh_token.token)
      |> then(&{:ok, &1})
    end
  end

  defp create_tokens({:error, changeset}), do: {:error, changeset}
end
