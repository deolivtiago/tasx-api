# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     TasxCore.Repo.insert!(%TasxCore.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

now = DateTime.utc_now(:second)

TasxCore.Repo.insert_all(TasxCore.Access.Roles.Role, [
  %{id: "user", permissions: ["GET:api/auth/user-info"], inserted_at: now, updated_at: now}
])
