defmodule TasxCore.Access.Roles.Role.List do
  @moduledoc false

  alias TasxCore.Access.Roles.Role
  alias TasxCore.Repo

  @doc false
  def call, do: Repo.all(Role)
end
