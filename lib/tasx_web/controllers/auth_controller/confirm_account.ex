defmodule TasxWeb.AuthController.ConfirmAccount do
  @moduledoc false

  import Ecto.Changeset

  alias TasxCore.Access.Users

  @doc false
  def handle(params) do
    params
    |> validate_params()
    |> confirm_account()
  end

  defp validate_params(params) do
    types = %{email: :string, code: :string}

    cast({%{}, types}, params, Map.keys(types))
    |> validate_required(Map.keys(types))
    |> update_change(:email, &String.downcase/1)
    |> validate_format(:email, ~r/^[a-z0-9._%+-]+@[a-z0-9.-]+\.[a-z]{2,}$/)
    |> validate_format(:code, ~r/^[0-9]+$/)
    |> validate_length(:code, is: 6)
    |> apply_action(:validate)
  end

  defp confirm_account({:ok, %{email: email, code: code}}) do
    with {:ok, user} <- Users.get_user(:email, email) do
      Users.confirm_user(user, code)
    end
  end

  defp confirm_account({:error, changeset}), do: {:error, changeset}
end
