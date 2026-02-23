defmodule TasxCore.Access.TokensTest do
  use TasxCore.DataCase, async: true

  import TasxCore.Access.UserFixtures
  import TasxCore.Access.TokenFixtures

  alias Ecto.Changeset
  alias TasxCore.Access.Tokens
  alias TasxCore.Access.Tokens.Token
  alias TasxCore.Access.Users.User

  setup do
    {:ok, user: insert_user()}
  end

  describe "list_tokens/0" do
    test "returns all users", %{user: user} do
      assert [] == Tokens.list_tokens()

      token = insert_token(user)

      assert [token] == Tokens.list_tokens()
    end
  end

  describe "verify_token/2 returns" do
    test "ok when access token is valid", %{user: user} do
      token = insert_token(user, typ: :access)

      assert {:ok, token} == Tokens.verify_token(token.token, :access)
    end

    test "ok when refresh token is valid", %{user: user} do
      token = insert_token(user, typ: :refresh)

      assert {:ok, token} == Tokens.verify_token(token.token, :refresh)
    end

    test "error when token is invalid" do
      assert {:error, changeset} = Tokens.verify_token("invalid_token", :access)
      errors = errors_on(changeset)

      assert Enum.member?(errors.token, "is invalid")
    end

    test "error when access token has a different type", %{user: user} do
      token = insert_token(user, typ: :refresh)

      assert {:error, changeset} = Tokens.verify_token(token.token, :access)
      errors = errors_on(changeset)

      assert Enum.member?(errors.token, "is invalid")
    end

    test "error when refresh token has a different type", %{user: user} do
      token = insert_token(user, typ: :access)

      assert {:error, changeset} = Tokens.verify_token(token.token, :refresh)
      errors = errors_on(changeset)

      assert Enum.member?(errors.token, "is invalid")
    end
  end

  describe "create_token_pair/1 returns" do
    test "ok when both tokens are valid", %{user: user} do
      assert {:ok, pair} = Tokens.create_token_pair(user)

      assert pair.access_token.user == user
      assert pair.access_token.type == :access
      assert pair.access_token.user_id == user.id
      assert DateTime.to_date(pair.access_token.expires_at) == Date.add(Date.utc_today(), 2)

      assert pair.refresh_token.user == user
      assert pair.refresh_token.type == :refresh
      assert pair.refresh_token.user_id == user.id
      assert DateTime.to_date(pair.refresh_token.expires_at) == Date.add(Date.utc_today(), 14)
    end

    test "error when user is invalid" do
      assert {:error, changeset} = Tokens.create_token_pair(%User{})
      errors = errors_on(changeset)

      assert %Changeset{valid?: false} = changeset
      assert Enum.member?(errors.token, "can't be signed")
    end
  end

  describe "create_token/2 returns" do
    test "ok when access token is valid", %{user: user} do
      assert {:ok, token} = Tokens.create_token(user, :access)

      assert token.user == user
      assert token.type == :access
      assert token.user_id == user.id
      assert DateTime.to_date(token.expires_at) == Date.add(Date.utc_today(), 2)
    end

    test "ok when refresh token is valid", %{user: user} do
      assert {:ok, token} = Tokens.create_token(user, :refresh)

      assert token.user == user
      assert token.type == :refresh
      assert token.user_id == user.id
      assert DateTime.to_date(token.expires_at) == Date.add(Date.utc_today(), 14)
    end

    test "error when user is invalid" do
      assert {:error, changeset} = Tokens.create_token(%User{}, :access)
      errors = errors_on(changeset)

      assert %Changeset{valid?: false} = changeset
      assert Enum.member?(errors.token, "can't be signed")
    end

    test "error when type is invalid", %{user: user} do
      assert {:error, changeset} = Tokens.create_token(user, :invalid_type)
      errors = errors_on(changeset)

      assert %Changeset{valid?: false} = changeset
      assert Enum.member?(errors.token, "can't be signed")
    end
  end

  describe "revoke_token/1" do
    test "returns ok token is revoked", %{user: user} do
      token = insert_token(user, typ: :access)

      assert {:ok, %Token{user: ^user}} = Tokens.revoke_token(token)
    end
  end
end
