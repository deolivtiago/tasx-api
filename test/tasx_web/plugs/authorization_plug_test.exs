defmodule TasxWeb.AuthorizationPlugTest do
  use TasxWeb.ConnCase, async: true

  import TasxCore.Access.UserFixtures
  import TasxCore.Access.RoleFixtures

  alias TasxWeb.AuthorizationPlug

  setup %{conn: conn} do
    conn
    |> put_req_header("accept", "application/json")
    |> then(&{:ok, conn: &1})
  end

  describe "init/1" do
    test "returns the given opts" do
      assert [some: :opt] = AuthorizationPlug.init(some: :opt)
    end
  end

  describe "call/2" do
    setup [:put_user]

    test "returns a conn when user has role root", %{conn: conn, user: user} do
      conn = assign(conn, :current_user, %{user | role_id: "root"})

      assert conn == AuthorizationPlug.call(conn, [])
    end

    test "returns a conn when permission matches", %{conn: conn, user: user} do
      conn = %{assign(conn, :current_user, user) | path_info: ["permitted", "path"]}

      assert conn == AuthorizationPlug.call(conn, [])
    end

    test "returns forbidden when permission doesn't match", %{conn: conn, user: user} do
      conn = %{assign(conn, :current_user, user) | path_info: ["forbidden", "path"]}
      expected = send_resp(conn, :forbidden, "") |> halt()

      assert expected == AuthorizationPlug.call(conn, [])
    end
  end

  defp put_user(_) do
    role_id = insert_role(%{permissions: ["GET:permitted/path"]}).id

    {:ok, user: insert_user(%{role_id: role_id})}
  end
end
