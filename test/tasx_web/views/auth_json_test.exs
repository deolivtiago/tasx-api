defmodule TasxWeb.AuthJsonTest do
  use TasxWeb.ConnCase, async: true

  import TasxCore.Access.UserFixtures

  alias TasxWeb.AuthJSON

  setup do
    {:ok, user: build_user()}
  end

  describe "renders" do
    test "a list of users", %{user: user} do
      assert %{data: [user_data]} = AuthJSON.index(%{users: [user]})

      assert user_data.id == user.id
      assert user_data.full_name == user.full_name
      assert user_data.email == user.email
      assert user_data.avatar_url == user.avatar_url
      assert user_data.role_id == user.role_id
      assert user_data.is_verified == user.verified?
    end

    test "a single user", %{user: user} do
      assert %{data: user_data} = AuthJSON.show(%{user: user})

      assert user_data.id == user.id
      assert user_data.full_name == user.full_name
      assert user_data.email == user.email
      assert user_data.avatar_url == user.avatar_url
      assert user_data.role_id == user.role_id
      assert user_data.is_verified == user.verified?
    end

    test "a token pair" do
      tokens = %{access_token: "access_token", refresh_token: "refresh_token"}

      assert %{data: auth_data} = AuthJSON.show(%{tokens: tokens})

      assert auth_data.access_token == tokens.access_token
      assert auth_data.refresh_token == tokens.refresh_token
    end
  end
end
