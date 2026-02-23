defmodule TasxCore.Access.Tokens.Token do
  @moduledoc false

  use Ecto.Schema

  import Ecto.Changeset

  alias TasxCore.Access.Users.User
  alias TasxCore.JsonWebToken

  @uuid_regex ~r/^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/

  @primary_key {:id, :binary_id, autogenerate: false}
  @foreign_key_type :binary_id

  schema "tokens" do
    field :token, :string
    field :expires_at, :utc_datetime

    field :type, Ecto.Enum, values: ~w(access refresh)a

    belongs_to :user, User

    timestamps(type: :utc_datetime, updated_at: false)
  end

  @doc false
  def changeset(%JsonWebToken{token: token, claims: claims}) do
    Map.new()
    |> Map.put(:token, token)
    |> Map.put(:id, claims.jti)
    |> Map.put(:type, claims.typ)
    |> Map.put(:user_id, claims.sub)
    |> Map.put(:expires_at, DateTime.from_unix!(claims.exp, :second))
    |> changeset()
  end

  def changeset(token \\ %__MODULE__{}, params) when is_map(params) do
    required_attrs = ~w(id token expires_at type user_id)a

    token
    |> cast(params, required_attrs)
    |> validate_required(required_attrs)
    |> unique_constraint(:id, name: :tokens_pkey)
    |> update_change(:id, &String.downcase/1)
    |> validate_format(:id, @uuid_regex)
    |> update_change(:user_id, &String.downcase/1)
    |> validate_format(:user_id, @uuid_regex)
    |> unique_constraint(:token)
    |> assoc_constraint(:user)
    |> foreign_key_constraint(:user_id)
  end
end
