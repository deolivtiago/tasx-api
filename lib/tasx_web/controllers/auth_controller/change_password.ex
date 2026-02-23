defmodule TasxWeb.AuthController.ChangePassword do
  @moduledoc false

  import Ecto.Changeset

  alias TasxCore.Access.Users

  @doc false
  def handle(params) do
    params
    |> validate_params()
    |> change_password()
  end

  defp validate_params(params) do
    types = %{email: :string, password: :string, new_password: :string}

    cast({%{}, types}, params, Map.keys(types))
    |> validate_required(Map.keys(types))
    |> update_change(:email, &String.downcase/1)
    |> validate_format(:email, ~r/^[a-z0-9._%+-]+@[a-z0-9.-]+\.[a-z]{2,}$/)
    |> apply_action(:validate)
  end

  defp change_password({:ok, %{email: email, password: password, new_password: new_password}}) do
    with {:ok, user} <- Users.authenticate_user(%{email: email, password: password}),
         {:error, changeset} <- Users.update_user(user, %{password: new_password}) do
      changeset.errors
      |> Enum.filter(&match?({:password, _}, &1))
      |> Enum.map(&{:new_password, elem(&1, 1)})
      |> then(&{:error, %{changeset | errors: &1}})
    end
  end

  defp change_password({:error, changeset}), do: {:error, changeset}
end
