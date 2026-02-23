defmodule TasxWeb.AuthenticationPlugTest do
  use TasxWeb.ConnCase, async: true

  import TasxCore.Access.UserFixtures
  import TasxCore.Access.TokenFixtures

  alias TasxWeb.AuthenticationPlug

  setup %{conn: conn} do
    conn
    |> put_req_header("accept", "application/json")
    |> then(&{:ok, conn: &1})
  end

  describe "init/1" do
    test "returns the given opts" do
      assert [some: :opt] = AuthenticationPlug.init(some: :opt)
    end
  end

  describe "call/2" do
    setup [:put_user]

    test "returns a conn with user when token is valid", %{conn: conn, user: user} do
      token = insert_token(user, typ: :access) |> Map.get(:token)
      conn = put_req_header(conn, "authorization", "Bearer #{token}")

      assert %{conn | assigns: %{current_user: user}} == AuthenticationPlug.call(conn, [])
    end

    test "returns unauthorized when token is invalid", %{conn: conn} do
      conn = put_req_header(conn, "authorization", "Bearer invalid.jwt.token")
      expected = send_resp(conn, :unauthorized, "") |> halt()

      assert expected == AuthenticationPlug.call(conn, [])
    end

    test "returns unauthorized when token is empty", %{conn: conn} do
      conn = put_req_header(conn, "authorization", "")
      expected = send_resp(conn, :unauthorized, "") |> halt()

      assert expected == AuthenticationPlug.call(conn, [])
    end
  end

  defp put_user(_) do
    {:ok, user: insert_user()}
  end
end
