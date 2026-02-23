defmodule TasxCore.Access.Tokens.TokenTest do
  use TasxCore.DataCase, async: true

  import TasxCore.Access.UserFixtures
  import TasxCore.JsonWebTokenFixtures

  alias Ecto.Changeset
  alias TasxCore.Access.Tokens.Token

  setup do
    {:ok, user: insert_user()}
  end

  describe "changeset/1 returns a valid changeset" do
    setup [:put_jwt]

    test "when id is valid", %{jwt: %{claims: claims} = jwt} do
      jwt = Map.put(jwt, :claims, Map.put(claims, :jti, String.upcase(claims.jti)))

      changeset = Token.changeset(jwt)

      assert %Changeset{valid?: true} = changeset
      assert Changeset.get_field(changeset, :id) == claims.jti
    end

    test "when token is valid", %{jwt: jwt} do
      changeset = Token.changeset(jwt)

      assert %Changeset{valid?: true} = changeset
      assert Changeset.get_field(changeset, :token) == jwt.token
    end

    test "when expires_at is valid", %{jwt: %{claims: claims} = jwt} do
      changeset = Token.changeset(jwt)

      assert %Changeset{valid?: true} = changeset
      assert Changeset.get_field(changeset, :expires_at) == DateTime.from_unix!(claims.exp)
    end

    test "when type is valid", %{jwt: %{claims: claims} = jwt} do
      changeset = Token.changeset(jwt)

      assert %Changeset{valid?: true} = changeset
      assert Changeset.get_field(changeset, :type) == claims.typ
    end

    test "when user id is valid", %{jwt: %{claims: claims} = jwt} do
      jwt = Map.put(jwt, :claims, Map.put(claims, :sub, String.upcase(claims.sub)))

      changeset = Token.changeset(jwt)

      assert %Changeset{valid?: true} = changeset
      assert Changeset.get_field(changeset, :user_id) == claims.sub
    end
  end

  describe "changeset/1 returns an invalid changeset" do
    setup [:put_jwt]

    test "when id is empty", %{jwt: %{claims: claims} = jwt} do
      jwt = Map.put(jwt, :claims, Map.put(claims, :jti, nil))

      changeset = Token.changeset(jwt)
      errors = errors_on(changeset)

      assert %Changeset{valid?: false} = changeset
      assert Enum.member?(errors.id, "can't be blank")
    end

    test "when id has invalid format", %{jwt: %{claims: claims} = jwt} do
      jwt = Map.put(jwt, :claims, Map.put(claims, :jti, "id.invalid"))

      changeset = Token.changeset(jwt)
      errors = errors_on(changeset)

      assert %Changeset{valid?: false} = changeset
      assert Enum.member?(errors.id, "has invalid format")
    end

    test "when id is invalid", %{jwt: %{claims: claims} = jwt} do
      jwt = Map.put(jwt, :claims, Map.put(claims, :jti, 1))

      changeset = Token.changeset(jwt)
      errors = errors_on(changeset)

      assert %Changeset{valid?: false} = changeset
      assert Enum.member?(errors.id, "is invalid")
    end

    test "when user id is empty", %{jwt: %{claims: claims} = jwt} do
      jwt = Map.put(jwt, :claims, Map.put(claims, :sub, nil))

      changeset = Token.changeset(jwt)
      errors = errors_on(changeset)

      assert %Changeset{valid?: false} = changeset
      assert Enum.member?(errors.user_id, "can't be blank")
    end

    test "when user id has invalid format", %{jwt: %{claims: claims} = jwt} do
      jwt = Map.put(jwt, :claims, Map.put(claims, :sub, "user_id.invalid"))

      changeset = Token.changeset(jwt)
      errors = errors_on(changeset)

      assert %Changeset{valid?: false} = changeset
      assert Enum.member?(errors.user_id, "has invalid format")
    end

    test "when user id is invalid", %{jwt: %{claims: claims} = jwt} do
      jwt = Map.put(jwt, :claims, Map.put(claims, :sub, 1))

      changeset = Token.changeset(jwt)
      errors = errors_on(changeset)

      assert %Changeset{valid?: false} = changeset
      assert Enum.member?(errors.user_id, "is invalid")
    end

    test "when token is empty", %{jwt: jwt} do
      jwt = Map.put(jwt, :token, nil)

      changeset = Token.changeset(jwt)
      errors = errors_on(changeset)

      assert %Changeset{valid?: false} = changeset
      assert Enum.member?(errors.token, "can't be blank")
    end

    test "when token is invalid", %{jwt: jwt} do
      jwt = Map.put(jwt, :token, 1)

      changeset = Token.changeset(jwt)
      errors = errors_on(changeset)

      assert %Changeset{valid?: false} = changeset
      assert Enum.member?(errors.token, "is invalid")
    end

    test "when type is empty", %{jwt: %{claims: claims} = jwt} do
      jwt = Map.put(jwt, :claims, Map.put(claims, :typ, nil))

      changeset = Token.changeset(jwt)
      errors = errors_on(changeset)

      assert %Changeset{valid?: false} = changeset
      assert Enum.member?(errors.type, "can't be blank")
    end

    test "when type is invalid", %{jwt: %{claims: claims} = jwt} do
      jwt = Map.put(jwt, :claims, Map.put(claims, :typ, "invalid.type"))

      changeset = Token.changeset(jwt)
      errors = errors_on(changeset)

      assert %Changeset{valid?: false} = changeset
      assert Enum.member?(errors.type, "is invalid")
    end
  end

  defp put_jwt(%{user: user}) do
    user
    |> build_jwt()
    |> then(&{:ok, jwt: &1})
  end
end
