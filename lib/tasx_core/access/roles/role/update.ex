defmodule TasxCore.Access.Roles.Role.Update do
  @moduledoc false

  alias TasxCore.Access.Roles.Role
  alias TasxCore.Repo

  @doc false
  def call(%Role{} = role, attrs) when is_map(attrs) do
    role
    |> Role.changeset(attrs)
    |> Repo.update()
  end
end
