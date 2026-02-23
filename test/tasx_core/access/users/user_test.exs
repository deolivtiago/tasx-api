defmodule TasxCore.Access.Users.UserTest do
  use TasxCore.DataCase, async: true

  import TasxCore.Access.UserFixtures

  alias Ecto.Changeset
  alias TasxCore.Access.Users.User

  setup do
    {:ok, attrs: user_attrs()}
  end

  describe "changeset/1 returns a valid changeset" do
    test "when full_name is valid", %{attrs: attrs} do
      changeset = User.changeset(attrs)

      assert %Changeset{valid?: true} = changeset
      assert Changeset.get_field(changeset, :full_name) == attrs.full_name
    end

    test "when email is valid", %{attrs: attrs} do
      attrs = Map.put(attrs, :email, String.upcase(attrs.email))

      changeset = User.changeset(attrs)

      assert %Changeset{valid?: true} = changeset
      assert Changeset.get_field(changeset, :email) == String.downcase(attrs.email)
    end

    test "when password is valid", %{attrs: attrs} do
      changeset = User.changeset(attrs)

      assert %Changeset{valid?: true, changes: changes} = changeset
      assert Argon2.verify_pass(attrs.password, changes.password)
    end

    test "when role_id is valid", %{attrs: attrs} do
      changeset = User.changeset(attrs)

      assert %Changeset{valid?: true} = changeset
      assert Changeset.get_field(changeset, :role_id) == attrs.role_id
    end

    test "when avatar_url is valid", %{attrs: attrs} do
      changeset = User.changeset(attrs)

      assert %Changeset{valid?: true} = changeset
      assert Changeset.get_field(changeset, :avatar_url) == attrs.avatar_url

      attrs = Map.delete(attrs, :avatar_url)
      assert %Changeset{valid?: true} = User.changeset(attrs)
    end

    test "when verified? is valid", %{attrs: attrs} do
      changeset = User.changeset(attrs)

      assert %Changeset{valid?: true} = changeset
      assert Changeset.get_field(changeset, :verified?) == attrs.verified?

      attrs = Map.delete(attrs, :verified?)
      assert %Changeset{valid?: true} = User.changeset(attrs)
    end

    test "when otp_secret is valid", %{attrs: attrs} do
      changeset = User.changeset(attrs)

      assert %Changeset{valid?: true} = changeset
      assert Changeset.get_field(changeset, :otp_secret) == attrs.otp_secret

      attrs = Map.delete(attrs, :otp_secret)
      assert %Changeset{valid?: true} = User.changeset(attrs)
    end
  end

  describe "changeset/1 returns an invalid changeset" do
    test "when full_name is too short", %{attrs: attrs} do
      attrs = Map.put(attrs, :full_name, "?")

      changeset = User.changeset(attrs)
      errors = errors_on(changeset)

      assert %Changeset{valid?: false} = changeset
      assert Enum.member?(errors.full_name, "should be at least 2 character(s)")
    end

    test "when full_name is empty", %{attrs: attrs} do
      attrs = Map.put(attrs, :full_name, "")

      changeset = User.changeset(attrs)
      errors = errors_on(changeset)

      assert %Changeset{valid?: false} = changeset
      assert Enum.member?(errors.full_name, "can't be blank")
    end

    test "when email is empty", %{attrs: attrs} do
      attrs = Map.put(attrs, :email, "")

      changeset = User.changeset(attrs)
      errors = errors_on(changeset)

      assert %Changeset{valid?: false} = changeset
      assert Enum.member?(errors.email, "can't be blank")
    end

    test "when email is too short", %{attrs: attrs} do
      attrs = Map.put(attrs, :email, "@@")

      changeset = User.changeset(attrs)
      errors = errors_on(changeset)

      assert %Changeset{valid?: false} = changeset
      assert Enum.member?(errors.email, "should be at least 3 character(s)")
    end

    test "when email has invalid format", %{attrs: attrs} do
      attrs = Map.put(attrs, :email, "email.invalid")

      changeset = User.changeset(attrs)
      errors = errors_on(changeset)

      assert %Changeset{valid?: false} = changeset
      assert Enum.member?(errors.email, "has invalid format")
    end

    test "when password is empty", %{attrs: attrs} do
      attrs = Map.put(attrs, :password, "")

      changeset = User.changeset(attrs)
      errors = errors_on(changeset)

      assert %Changeset{valid?: false} = changeset
      assert Enum.member?(errors.password, "can't be blank")
    end

    test "when password is too short", %{attrs: attrs} do
      attrs = Map.put(attrs, :password, "?")

      changeset = User.changeset(attrs)
      errors = errors_on(changeset)

      assert %Changeset{valid?: false} = changeset
      assert Enum.member?(errors.password, "should be at least 6 character(s)")
    end

    test "when password doesn't have number(s)", %{attrs: attrs} do
      attrs = Map.put(attrs, :password, "Password?")

      changeset = User.changeset(attrs)
      errors = errors_on(changeset)

      assert %Changeset{valid?: false} = changeset
      assert Enum.member?(errors.password, "must have number(s)")
    end

    test "when password doesn't have lowercase character(s)", %{attrs: attrs} do
      attrs = Map.put(attrs, :password, "P455W0RD?")

      changeset = User.changeset(attrs)
      errors = errors_on(changeset)

      assert %Changeset{valid?: false} = changeset
      assert Enum.member?(errors.password, "must have lowercase character(s)")
    end

    test "when password doesn't have uppercase character(s)", %{attrs: attrs} do
      attrs = Map.put(attrs, :password, "p455w0rd?")

      changeset = User.changeset(attrs)
      errors = errors_on(changeset)

      assert %Changeset{valid?: false} = changeset
      assert Enum.member?(errors.password, "must have uppercase character(s)")
    end

    test "when password doesn't have special character(s)", %{attrs: attrs} do
      attrs = Map.put(attrs, :password, "P455w0rd")

      changeset = User.changeset(attrs)
      errors = errors_on(changeset)

      assert %Changeset{valid?: false} = changeset
      assert Enum.member?(errors.password, "must have special character(s)")
    end

    test "when role_id is too short", %{attrs: attrs} do
      attrs = Map.put(attrs, :role_id, "@@")

      changeset = User.changeset(attrs)
      errors = errors_on(changeset)

      assert %Changeset{valid?: false} = changeset
      assert Enum.member?(errors.role_id, "has invalid format")
    end

    test "when role_id is invalid", %{attrs: attrs} do
      attrs = Map.put(attrs, :role_id, :invalid_role)

      changeset = User.changeset(attrs)
      errors = errors_on(changeset)

      assert %Changeset{valid?: false} = changeset
      assert Enum.member?(errors.role_id, "is invalid")
    end

    test "when verified? is invalid", %{attrs: attrs} do
      attrs = Map.put(attrs, :verified?, "invalid.value")

      changeset = User.changeset(attrs)
      errors = errors_on(changeset)

      assert %Changeset{valid?: false} = changeset
      assert Enum.member?(errors.verified?, "is invalid")
    end

    test "when otp_secret is invalid", %{attrs: attrs} do
      attrs = Map.put(attrs, :otp_secret, 1)

      changeset = User.changeset(attrs)
      errors = errors_on(changeset)

      assert %Changeset{valid?: false} = changeset
      assert Enum.member?(errors.otp_secret, "is invalid")
    end
  end

  describe "changeset/2 returns a valid changeset" do
    setup [:put_user]

    test "when avatar_url is valid", %{attrs: attrs, user: user} do
      changeset = User.changeset(user, attrs)

      assert %Changeset{valid?: true} = changeset
      assert Changeset.get_field(changeset, :avatar_url) == attrs.avatar_url

      attrs = Map.delete(attrs, :avatar_url)
      assert %Changeset{valid?: true} = User.changeset(user, attrs)
    end

    test "when full_name is valid", %{attrs: attrs, user: user} do
      changeset = User.changeset(user, attrs)

      assert %Changeset{valid?: true} = changeset
      assert Changeset.get_field(changeset, :full_name) == attrs.full_name
    end

    test "when email is valid", %{attrs: attrs, user: user} do
      attrs = Map.put(attrs, :email, String.upcase(attrs.email))

      changeset = User.changeset(user, attrs)

      assert %Changeset{valid?: true} = changeset
      assert Changeset.get_field(changeset, :email) == String.downcase(attrs.email)
    end

    test "when password is valid", %{attrs: attrs, user: user} do
      changeset = User.changeset(user, attrs)

      assert %Changeset{valid?: true, changes: changes} = changeset
      assert Argon2.verify_pass(attrs.password, changes.password)
    end

    test "when role_id is valid", %{attrs: attrs, user: user} do
      changeset = User.changeset(user, attrs)

      assert %Changeset{valid?: true} = changeset
      assert Changeset.get_field(changeset, :role_id) == attrs.role_id

      attrs = Map.delete(attrs, :role_id)
      assert %Changeset{valid?: true} = User.changeset(user, attrs)
    end

    test "when verified? is valid", %{attrs: attrs, user: user} do
      changeset = User.changeset(user, attrs)

      assert %Changeset{valid?: true} = changeset
      assert Changeset.get_field(changeset, :verified?) == attrs.verified?

      attrs = Map.delete(attrs, :verified?)
      assert %Changeset{valid?: true} = User.changeset(user, attrs)
    end

    test "when otp_secret is valid", %{attrs: attrs, user: user} do
      changeset = User.changeset(user, attrs)

      assert %Changeset{valid?: true} = changeset
      assert Changeset.get_field(changeset, :otp_secret) == attrs.otp_secret

      attrs = Map.delete(attrs, :otp_secret)
      assert %Changeset{valid?: true} = User.changeset(user, attrs)
    end
  end

  describe "changeset/2 returns an invalid changeset" do
    setup [:put_user]

    test "when full_name is too short", %{attrs: attrs, user: user} do
      attrs = Map.put(attrs, :full_name, "?")

      changeset = User.changeset(user, attrs)
      errors = errors_on(changeset)

      assert %Changeset{valid?: false} = changeset
      assert Enum.member?(errors.full_name, "should be at least 2 character(s)")
    end

    test "when full_name is empty", %{attrs: attrs, user: user} do
      attrs = Map.put(attrs, :full_name, "")

      changeset = User.changeset(user, attrs)
      errors = errors_on(changeset)

      assert %Changeset{valid?: false} = changeset
      assert Enum.member?(errors.full_name, "can't be blank")
    end

    test "when email is empty", %{attrs: attrs, user: user} do
      attrs = Map.put(attrs, :email, "")

      changeset = User.changeset(user, attrs)
      errors = errors_on(changeset)

      assert %Changeset{valid?: false} = changeset
      assert Enum.member?(errors.email, "can't be blank")
    end

    test "when email has invalid format", %{attrs: attrs, user: user} do
      attrs = Map.put(attrs, :email, "email.invalid")

      changeset = User.changeset(user, attrs)
      errors = errors_on(changeset)

      assert %Changeset{valid?: false} = changeset
      assert Enum.member?(errors.email, "has invalid format")
    end

    test "when email is too short", %{attrs: attrs, user: user} do
      attrs = Map.put(attrs, :email, "@@")

      changeset = User.changeset(user, attrs)
      errors = errors_on(changeset)

      assert %Changeset{valid?: false} = changeset
      assert Enum.member?(errors.email, "should be at least 3 character(s)")
    end

    test "when password is too short", %{attrs: attrs, user: user} do
      attrs = Map.put(attrs, :password, "?")

      changeset = User.changeset(user, attrs)
      errors = errors_on(changeset)

      assert %Changeset{valid?: false} = changeset
      assert Enum.member?(errors.password, "should be at least 6 character(s)")
    end

    test "when password is empty", %{attrs: attrs, user: user} do
      attrs = Map.put(attrs, :password, "")

      changeset = User.changeset(user, attrs)
      errors = errors_on(changeset)

      assert %Changeset{valid?: false} = changeset
      assert Enum.member?(errors.password, "can't be blank")
    end

    test "when password doesn't have number(s)", %{attrs: attrs, user: user} do
      attrs = Map.put(attrs, :password, "Password?")

      changeset = User.changeset(user, attrs)
      errors = errors_on(changeset)

      assert %Changeset{valid?: false} = changeset
      assert Enum.member?(errors.password, "must have number(s)")
    end

    test "when password doesn't have lowercase character(s)", %{attrs: attrs, user: user} do
      attrs = Map.put(attrs, :password, "P455W0RD?")

      changeset = User.changeset(user, attrs)
      errors = errors_on(changeset)

      assert %Changeset{valid?: false} = changeset
      assert Enum.member?(errors.password, "must have lowercase character(s)")
    end

    test "when password doesn't have uppercase character(s)", %{attrs: attrs, user: user} do
      attrs = Map.put(attrs, :password, "p455w0rd?")

      changeset = User.changeset(user, attrs)
      errors = errors_on(changeset)

      assert %Changeset{valid?: false} = changeset
      assert Enum.member?(errors.password, "must have uppercase character(s)")
    end

    test "when password doesn't have special character(s)", %{attrs: attrs, user: user} do
      attrs = Map.put(attrs, :password, "p455w0rd")

      changeset = User.changeset(user, attrs)
      errors = errors_on(changeset)

      assert %Changeset{valid?: false} = changeset
      assert Enum.member?(errors.password, "must have special character(s)")
    end

    test "when verified? is invalid", %{attrs: attrs, user: user} do
      attrs = Map.put(attrs, :verified?, "invalid.value")

      changeset = User.changeset(user, attrs)
      errors = errors_on(changeset)

      assert %Changeset{valid?: false} = changeset
      assert Enum.member?(errors.verified?, "is invalid")
    end

    test "when otp_secret is invalid", %{attrs: attrs, user: user} do
      attrs = Map.put(attrs, :otp_secret, 1)

      changeset = User.changeset(user, attrs)
      errors = errors_on(changeset)

      assert %Changeset{valid?: false} = changeset
      assert Enum.member?(errors.otp_secret, "is invalid")
    end
  end

  describe "new_verification_code/1 and valid_verification_code/2" do
    setup [:put_user]

    test "generate and validate verification codes", %{user: user} do
      assert code = User.new_verification_code(user)
      assert User.valid_verification_code?(user, code)
      refute User.valid_verification_code?(user, "invalid.code")
    end
  end

  defp put_user(_) do
    {:ok, user: build_user()}
  end
end
