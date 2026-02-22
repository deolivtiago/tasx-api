defmodule TasxCore.Access.Users.User do
  @moduledoc false
  use Ecto.Schema

  import Ecto.Changeset

  alias TasxCore.Access.Roles.Role

  @otp_opts [period: 300]

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "users" do
    field :full_name, :string, default: ""

    field :email, :string
    field :password, :string, redact: true

    field :avatar_url, :string, default: ""

    field :otp_secret, :binary, autogenerate: {NimbleTOTP, :secret, []}, redact: true
    field :verified?, :boolean, source: :is_verified, default: false

    belongs_to :role, Role, type: :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(user \\ %__MODULE__{role_id: "user"}, attrs) when is_map(attrs) do
    required_attrs = ~w(full_name email password)a
    optional_attrs = ~w(avatar_url otp_secret verified? role_id)a

    user
    |> cast(attrs, required_attrs ++ optional_attrs)
    |> validate_required(required_attrs)
    |> unique_constraint(:id, name: :users_pkey)
    |> validate_length(:full_name, min: 2, max: 255)
    |> unique_constraint(:email, name: :users_email_index)
    |> update_change(:email, &String.downcase/1)
    |> validate_length(:email, min: 3, max: 160)
    |> validate_format(:email, ~r/^[a-z0-9._%+-]+@[a-z0-9.-]+\.[a-z]{2,}$/)
    |> validate_length(:password, min: 6, max: 72)
    |> validate_length(:password, max: 72, count: :bytes)
    |> validate_format(:password, ~r/[0-9]/, message: "must have number(s)")
    |> validate_format(:password, ~r/[a-z]/, message: "must have lowercase character(s)")
    |> validate_format(:password, ~r/[A-Z]/, message: "must have uppercase character(s)")
    |> validate_format(:password, ~r/[^0-9a-zA-Z]/, message: "must have special character(s)")
    |> update_change(:password, &Argon2.hash_pwd_salt/1)
    |> validate_length(:avatar_url, max: 255)
    |> validate_format(:role_id, ~r/^[a-zA-Z0-9_]+$/)
    |> validate_length(:role_id, max: 64)
    |> validate_exclusion(:role_id, ~w(root), message: "is invalid")
    |> foreign_key_constraint(:role_id)
    |> assoc_constraint(:role)
  end

  @doc ~S"""
  Returns a verification code for the given user

    ## Examples

        iex> new_verification_code(user)
        "123456"
  """
  def new_verification_code(%__MODULE__{otp_secret: otp_secret}, opts \\ @otp_opts),
    do: NimbleTOTP.verification_code(otp_secret, opts)

  @doc ~S"""
  Validates the given verification code for an user

  ## Examples

      iex> valid_verification_code(user, code)
      true

  """
  def valid_verification_code?(%__MODULE__{otp_secret: otp_secret}, code, opts \\ @otp_opts)
      when is_binary(code),
      do: NimbleTOTP.valid?(otp_secret, code, opts)
end
