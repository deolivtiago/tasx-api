defmodule TasxCore.Access.UsersTest do
  use TasxCore.DataCase, async: true

  import TasxCore.Access.UserFixtures

  alias Ecto.Changeset
  alias TasxCore.Access.Users
  alias TasxCore.Access.Users.User

  setup do
    {:ok, attrs: user_attrs()}
  end

  describe "list_users/0" do
    test "returns all users" do
      assert [] == Users.list_users()

      user = insert_user()

      assert [user] == Users.list_users()
    end
  end

  describe "get_user/3 returns" do
    setup [:put_user]

    test "ok when the user_id is found", %{user: user} do
      assert {:ok, user} == Users.get_user(:id, user.id)
    end

    test "error when the user_id is not found" do
      id = Ecto.UUID.generate()

      assert {:error, changeset} = Users.get_user(:id, id)
      errors = errors_on(changeset)

      assert %Changeset{valid?: false} = changeset
      assert Enum.member?(errors.id, "not found")
    end

    test "ok when the email is found", %{user: user} do
      assert {:ok, user} == Users.get_user(:email, user.email)
    end

    test "error when the email is not found" do
      assert {:error, changeset} = Users.get_user(:email, "not.found@mail.com")
      errors = errors_on(changeset)

      assert %Changeset{valid?: false} = changeset
      assert Enum.member?(errors.email, "not found")
    end

    test "ok when the email is verified", %{user: user} do
      assert {:ok, user} == Users.get_user(:email, user.email, verified?: true)
    end

    test "error when the email is not verified" do
      user = insert_user(%{verified?: false})

      assert {:error, changeset} = Users.get_user(:email, user.email, verified?: true)
      errors = errors_on(changeset)

      assert %Changeset{valid?: false} = changeset
      assert Enum.member?(errors.email, "must be verified")
    end
  end

  describe "create_user/1 returns" do
    test "ok when the user attrs are valid", %{attrs: attrs} do
      assert {:ok, %User{} = user} = Users.create_user(attrs)

      assert user.full_name == attrs.full_name
      assert user.email == attrs.email
      assert user.role_id == attrs.role_id
      assert Argon2.verify_pass(attrs.password, user.password)
    end

    test "error when the user attrs are invalid" do
      attrs = %{email: "???", full_name: nil, password: "?", role_id: :invalid}

      assert {:error, changeset} = Users.create_user(attrs)
      errors = errors_on(changeset)

      assert %Changeset{valid?: false} = changeset
      assert Enum.member?(errors.full_name, "can't be blank")
      assert Enum.member?(errors.email, "has invalid format")
      assert Enum.member?(errors.password, "should be at least 6 character(s)")
      assert Enum.member?(errors.role_id, "is invalid")
    end

    test "error when the email already exists", %{attrs: attrs} do
      attrs = Map.put(attrs, :email, insert_user().email)

      assert {:error, changeset} = Users.create_user(attrs)
      errors = errors_on(changeset)

      assert %Changeset{valid?: false} = changeset
      assert Enum.member?(errors.email, "has already been taken")
    end
  end

  describe "update_user/2 returns" do
    setup [:put_user]

    test "ok when the user attrs are valid", %{user: %{id: id} = user, attrs: attrs} do
      assert {:ok, %User{id: ^id} = user} = Users.update_user(user, attrs)

      assert attrs.id != user.id
      assert attrs.full_name == user.full_name
      assert attrs.role_id == user.role_id
      assert Argon2.verify_pass(attrs.password, user.password)
    end

    test "error when the user attrs are invalid", %{user: user} do
      invalid_attrs = %{email: "?@?", full_name: "", password: "?", role_id: 0}

      assert {:error, changeset} = Users.update_user(user, invalid_attrs)
      errors = errors_on(changeset)

      assert %Changeset{valid?: false} = changeset
      assert Enum.member?(errors.full_name, "can't be blank")
      assert Enum.member?(errors.email, "has invalid format")
      assert Enum.member?(errors.password, "should be at least 6 character(s)")
      assert Enum.member?(errors.role_id, "is invalid")
    end
  end

  describe "delete_user/1 returns" do
    setup [:put_user]

    test "ok when the user is deleted", %{user: user} do
      assert {:ok, %User{}} = Users.delete_user(user)

      assert {:error, changeset} = Users.delete_user(user)
      errors = errors_on(changeset)

      assert %Changeset{valid?: false} = changeset
      assert Enum.member?(errors.id, "not found")
    end
  end

  describe "authenticate/2 returns" do
    test "ok when the password is valid", %{attrs: attrs} do
      user = insert_user(attrs)

      assert {:ok, user} == Users.authenticate_user(attrs)
    end

    test "error when the email is invalid", %{attrs: attrs} do
      insert_user(attrs)
      attrs = %{email: "another@mail.com", password: attrs.password}

      assert {:error, changeset} = Users.authenticate_user(attrs)
      errors = errors_on(changeset)

      assert %Changeset{valid?: false} = changeset
      assert Enum.member?(errors.email, "invalid credentials")
      assert Enum.member?(errors.password, "invalid credentials")
    end

    test "error when the email is not verified", %{attrs: attrs} do
      insert_user(%{attrs | verified?: false})

      assert {:error, changeset} = Users.authenticate_user(attrs)
      errors = errors_on(changeset)

      assert %Changeset{valid?: false} = changeset
      assert Enum.member?(errors.email, "must be verified")
    end

    test "error when the password is invalid", %{attrs: attrs} do
      attrs = %{email: insert_user(attrs).email, password: "invalid.password"}

      assert {:error, changeset} = Users.authenticate_user(attrs)
      errors = errors_on(changeset)

      assert %Changeset{valid?: false} = changeset
      assert Enum.member?(errors.email, "invalid credentials")
      assert Enum.member?(errors.password, "invalid credentials")
    end
  end

  describe "verify_user/2 returns ok" do
    setup [:put_user]

    test "when the verification email has been sent", %{user: user} do
      assert {:ok, %Swoosh.Email{}} = Users.verify_user(user)
    end
  end

  describe "confirm_user/2 returns" do
    test "ok when the code is valid" do
      user = insert_user(%{verified?: false})
      code = User.new_verification_code(user)

      attrs = %{verified?: true, password: "NewP455w0rd!", email: "another@email.com"}

      assert {:ok, changed_user} = Users.confirm_user(user, code, attrs)

      assert changed_user.verified? == attrs.verified?
      assert changed_user.email == attrs.email
      refute changed_user.password == user.password
    end

    test "error when the code is invalid" do
      user = insert_user()

      assert {:error, changeset} = Users.confirm_user(user, "666666")
      errors = errors_on(changeset)

      assert %Changeset{valid?: false} = changeset
      assert Enum.member?(errors.code, "is invalid")
    end

    test "error when attrs are invalid" do
      user = insert_user()
      code = User.new_verification_code(user)

      attrs = %{password: "???", email: "???"}

      assert {:error, changeset} = Users.confirm_user(user, code, attrs)
      errors = errors_on(changeset)

      assert %Changeset{valid?: false} = changeset
      assert Enum.member?(errors.email, "has invalid format")
      assert Enum.member?(errors.password, "must have lowercase character(s)")
    end
  end

  defp put_user(_) do
    {:ok, user: insert_user()}
  end
end
