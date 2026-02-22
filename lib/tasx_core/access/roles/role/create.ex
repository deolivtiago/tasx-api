defmodule TasxCore.Access.Roles.Role.Create do
  @moduledoc false

  alias TasxCore.Access.Roles.Role
  alias TasxCore.Repo

  @doc false
  def call(attrs) when is_map(attrs) do
    attrs
    |> Role.changeset()
    |> Repo.insert()
  end
end
