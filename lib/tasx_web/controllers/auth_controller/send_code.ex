defmodule TasxWeb.AuthController.SendCode do
  @moduledoc false

  import Ecto.Changeset

  alias TasxCore.Access.Users

  @doc false
  def handle(params) do
    params
    |> validate_params()
    |> verify_user()
  end

  defp validate_params(params) do
    types = %{email: :string}

    cast({%{}, types}, params, Map.keys(types))
    |> validate_required(Map.keys(types))
    |> update_change(:email, &String.downcase/1)
    |> validate_format(:email, ~r/^[a-z0-9._%+-]+@[a-z0-9.-]+\.[a-z]{2,}$/)
    |> apply_action(:validate)
  end

  defp verify_user({:ok, %{email: email}}) do
    with {:ok, user} <- Users.get_user(:email, email),
         {:ok, _email} <- Users.verify_user(user) do
      {:ok, user}
    end
  end

  defp verify_user({:error, changeset}), do: {:error, changeset}
end
