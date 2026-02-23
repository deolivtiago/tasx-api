defmodule TasxCore.JsonWebToken do
  @moduledoc false

  use Ecto.Schema

  import Ecto.Changeset

  @alg "HS256"
  @uuid_regex ~r/^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/

  @primary_key false
  @timestamps_opts false

  embedded_schema do
    field :token, :string

    embeds_one :claims, Claims, primary_key: {:jti, :binary_id, autogenerate: false} do
      field :sub, :binary_id

      field :typ, Ecto.Enum, values: ~w(access refresh)a, default: :access

      field :iat, :integer
      field :exp, :integer

      field :iss, :string, default: "web_server"
      field :aud, :string, default: "web_client"
    end
  end

  @doc """
  Converts the given payload to a `JsonWebToken`

  ## Examples

      iex> from_payload(payload)
      {:ok, %JsonWebToken{}}

      iex> from_payload(bad_payload)
      {:error, %Ecto.Changeset{}}

  """
  def from_payload(payload) when is_map(payload) do
    with {:ok, claims} <- claims_from_payload(payload),
         {_alg, signed_map} <- JOSE.JWT.sign(jwk(), jws(), Map.from_struct(claims)),
         {_alg, token} <- JOSE.JWS.compact(signed_map) do
      {:ok, %__MODULE__{token: token, claims: claims}}
    else
      {:error, changeset} ->
        %__MODULE__{}
        |> change(%{claims: changeset})
        |> add_error(:claims, "is invalid")
        |> then(&{:error, &1})
    end
  end

  @doc """
  Converts the given token to a `JsonWebToken`

  ## Examples

      iex> from_token("json.web.token")
      {:ok, %JsonWebToken{}}

      iex> from_token("invalid.token")
      {:error, %Ecto.Changeset{}}

  """
  def from_token(token) when is_binary(token) do
    with {true, %{fields: payload}, _jws} <- JOSE.JWT.verify_strict(jwk(), [@alg], token),
         {:ok, claims} <- claims_from_payload(payload) do
      {:ok, %__MODULE__{token: token, claims: claims}}
    else
      _error ->
        %__MODULE__{}
        |> change(%{token: token})
        |> add_error(:token, "is invalid")
        |> then(&{:error, &1})
    end
  end

  defp claims_from_payload(payload) when is_map(payload) do
    required_fields = ~w(sub typ)a
    optional_fields = ~w(jti iss aud)a

    %__MODULE__.Claims{}
    |> cast(payload, required_fields ++ optional_fields)
    |> validate_required(required_fields)
    |> update_change(:sub, &String.downcase/1)
    |> validate_format(:sub, @uuid_regex)
    |> put_change(:exp)
    |> put_change(:jti)
    |> apply_action(:build)
  end

  defp put_change(%{valid?: true} = changeset, :exp) do
    iat = DateTime.utc_now(:second)

    exp =
      if match?(:refresh, get_field(changeset, :typ)),
        do: DateTime.add(iat, 14, :day),
        else: DateTime.add(iat, 2, :day)

    changeset
    |> put_change(:iat, DateTime.to_unix(iat))
    |> put_change(:exp, DateTime.to_unix(exp))
  end

  defp put_change(%{valid?: true} = changeset, :jti) do
    if get_field(changeset, :jti) do
      changeset
      |> update_change(:jti, &String.downcase/1)
      |> validate_format(:jti, @uuid_regex)
    else
      put_change(changeset, :jti, Ecto.UUID.generate())
    end
  end

  defp put_change(changeset, _field), do: changeset

  defp jwk do
    :tasx
    |> Application.fetch_env!(__MODULE__)
    |> Keyword.fetch!(:jwt_secret_key)
    |> JOSE.JWK.from_oct()
  end

  defp jws do
    Map.new()
    |> Map.put("typ", "JWT")
    |> Map.put("alg", @alg)
    |> JOSE.JWS.from()
  end
end
