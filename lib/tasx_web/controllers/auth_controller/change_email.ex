defmodule TasxWeb.AuthController.ChangeEmail do
  @moduledoc false

  import Ecto.Changeset

  alias TasxCore.Access.Users

  @doc false
  def handle(params) do
    params
    |> validate_params()
    |> change_email()
  end

  defp validate_params(params) do
    types = %{email: :string, password: :string, new_email: :string}

    cast({%{}, types}, params, Map.keys(types))
    |> validate_required(Map.keys(types))
    |> update_change(:email, &String.downcase/1)
    |> validate_format(:email, ~r/^[a-z0-9._%+-]+@[a-z0-9.-]+\.[a-z]{2,}$/)
    |> apply_action(:validate)
  end

  defp change_email({:ok, %{email: email, password: password, new_email: new_email}}) do
    with {:ok, user} <- Users.authenticate_user(%{email: email, password: password}),
         {:error, changeset} <- Users.update_user(user, %{verified?: false, email: new_email}) do
      changeset.errors
      |> Enum.filter(&match?({:email, _}, &1))
      |> Enum.map(&{:new_email, elem(&1, 1)})
      |> then(&{:error, %{changeset | errors: &1}})
    end
  end

  defp change_email({:error, changeset}), do: {:error, changeset}
end
