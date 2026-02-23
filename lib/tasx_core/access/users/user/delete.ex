defmodule TasxCore.Access.Users.User.Delete do
  @moduledoc false

  alias TasxCore.Access.Users.User
  alias TasxCore.Repo

  @opts [stale_error_field: :id, stale_error_message: "not found"]

  @doc false
  def call(%User{} = user), do: Repo.delete(user, @opts)
end
