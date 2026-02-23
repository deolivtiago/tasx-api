defmodule TasxCore.JsonWebTokenTest do
  use TasxCore.DataCase, async: true

  import TasxCore.Access.UserFixtures
  import TasxCore.JsonWebTokenFixtures

  alias Ecto.Changeset
  alias TasxCore.JsonWebToken

  setup do
    {:ok, user: insert_user()}
  end

  describe "from_payload/1" do
    test "returns ok when payload is valid", %{user: %{id: sub}} do
      payload = %{sub: sub, typ: Enum.random(~w(access refresh)a)}

      assert {:ok, %JsonWebToken{} = jwt} = JsonWebToken.from_payload(payload)

      exp =
        if match?(:refresh, jwt.claims.typ),
          do: DateTime.add(DateTime.from_unix!(jwt.claims.iat), 14, :day),
          else: DateTime.add(DateTime.from_unix!(jwt.claims.iat), 2, :day)

      assert jwt.token
      assert jwt.claims.jti
      assert jwt.claims.sub == payload.sub
      assert jwt.claims.typ == payload.typ
      assert jwt.claims.iss == "web_server"
      assert jwt.claims.aud == "web_client"
      assert jwt.claims.exp == DateTime.to_unix(exp)
    end

    test "returns error when payload is invalid" do
      payload = %{sub: nil, typ: :invalid_typ}

      assert {:error, changeset} = JsonWebToken.from_payload(payload)
      errors = errors_on(changeset)

      assert %Changeset{valid?: false} = changeset
      assert Enum.member?(errors.claims.sub, "can't be blank")
      assert Enum.member?(errors.claims.typ, "is invalid")
    end
  end

  describe "from_token/1" do
    setup [:put_jwt]

    test "returns ok when token is valid", %{jwt: jwt} do
      assert {:ok, jwt} == JsonWebToken.from_token(jwt.token)
    end

    test "returns error when token is invalid" do
      assert {:error, changeset} = JsonWebToken.from_token("invalid_token")
      errors = errors_on(changeset)

      assert %Changeset{valid?: false} = changeset
      assert Enum.member?(errors.token, "is invalid")
    end
  end

  defp put_jwt(%{user: user}) do
    user
    |> build_jwt()
    |> then(&{:ok, jwt: &1})
  end
end
