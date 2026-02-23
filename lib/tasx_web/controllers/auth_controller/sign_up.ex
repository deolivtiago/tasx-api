defmodule TasxWeb.AuthController.SignUp do
  @moduledoc false

  import Ecto.Changeset

  alias TasxCore.Access.Users

  @doc false
  def handle(params) do
    params
    |> validate_params()
    |> create_user()
  end

  defp validate_params(params) do
    types = %{full_name: :string, avatar_url: :string, email: :string, password: :string}
    optional = ~w(avatar_url)a

    cast({%{}, types}, params, Map.keys(types))
    |> validate_required(Enum.reject(Map.keys(types), &Enum.member?(optional, &1)))
    |> validate_length(:full_name, min: 2, max: 255)
    |> update_change(:email, &String.downcase/1)
    |> validate_length(:email, min: 3, max: 160)
    |> validate_format(:email, ~r/^[a-z0-9._%+-]+@[a-z0-9.-]+\.[a-z]{2,}$/)
    |> validate_length(:password, min: 6, max: 72)
    |> validate_length(:password, max: 72, count: :bytes)
    |> validate_format(:password, ~r/[0-9]/, message: "must have number(s)")
    |> validate_format(:password, ~r/[a-z]/, message: "must have lowercase character(s)")
    |> validate_format(:password, ~r/[A-Z]/, message: "must have uppercase character(s)")
    |> validate_format(:password, ~r/[^0-9a-zA-Z]/, message: "must have special character(s)")
    |> update_change(:avatar_url, &String.downcase/1)
    |> validate_length(:avatar_url, max: 255)
    |> apply_action(:validate)
  end

  defp create_user({:ok, user_attrs}), do: Users.create_user(user_attrs)
  defp create_user({:error, changeset}), do: {:error, changeset}
end
