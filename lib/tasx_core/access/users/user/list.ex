defmodule TasxCore.Access.Users.User.List do
  @moduledoc false

  alias TasxCore.Access.Users.User
  alias TasxCore.Repo

  @doc false
  def call do
    User
    |> Repo.all()
    |> Repo.preload(:role)
  end
end
