defmodule TasxCore.JsonWebTokenFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `TasxCore.JsonWebToken` context.
  """
  alias TasxCore.Access.Users.User
  alias TasxCore.JsonWebToken

  @doc """
  Builds a fake `JsonWebToken`

    ## Examples

      iex> build_jwt(user, token_type, opts)
      %JsonWebToken{}

  """
  def build_jwt(%User{} = user, opts \\ []) do
    typ = Keyword.get(opts, :typ, Enum.random(~w(access refresh)a))

    Map.new()
    |> Map.put(:sub, user.id)
    |> Map.put(:typ, typ)
    |> JsonWebToken.from_payload()
    |> elem(1)
  end

  @doc """
  Builds a fake token

    ## Examples

      iex> build_token(payload, opts)
      "json.web.token"

  """
  def build_token(payload \\ %{}, opts \\ []) when is_map(payload) and not is_struct(payload) do
    secret = Keyword.get(opts, :secret, jwt_secret())
    alg = Keyword.get(opts, :alg, "HS256")

    jwk = JOSE.JWK.from_oct(secret)
    jws = JOSE.JWS.from(%{"typ" => "JWT", "alg" => alg})
    jwt = JOSE.JWT.from(payload)

    JOSE.JWT.sign(jwk, jws, jwt) |> elem(1) |> JOSE.JWS.compact() |> elem(1)
  end

  defp jwt_secret do
    :tasx
    |> Application.fetch_env!(JsonWebToken)
    |> Keyword.fetch!(:jwt_secret_key)
  end
end
