defmodule TasxCore.Access.Roles.Role.Get do
  @moduledoc false

  import Ecto.Changeset

  alias TasxCore.Access.Roles.Role
  alias TasxCore.Repo

  @doc false
  def call(:id, value) when is_binary(value) do
    case Repo.get_by(Role, id: value) do
      %Role{} = role ->
        {:ok, role}

      nil ->
        %Role{}
        |> change()
        |> add_error(:id, "not found")
        |> then(&{:error, &1})
    end
  end
end
