defmodule TasxCore.Access.RolesTest do
  use TasxCore.DataCase, async: true

  import TasxCore.Access.RoleFixtures
  import TasxCore.Access.UserFixtures

  alias Ecto.Changeset
  alias TasxCore.Access.Roles
  alias TasxCore.Access.Roles.Role

  setup do
    delete_roles()

    {:ok, attrs: role_attrs()}
  end

  describe "list_roles/0" do
    test "returns all roles" do
      assert [] == Roles.list_roles()

      role = insert_role()

      assert [role] == Roles.list_roles()
    end
  end

  describe "get_role/2 returns" do
    setup [:put_role]

    test "ok when role_id is found", %{role: role} do
      assert {:ok, role} == Roles.get_role(:id, role.id)
    end

    test "error when role_id is not found" do
      assert {:error, changeset} = Roles.get_role(:id, "not_found_id")
      errors = errors_on(changeset)

      assert %Changeset{valid?: false} = changeset
      assert Enum.member?(errors.id, "not found")
    end
  end

  describe "create_role/1 returns" do
    test "ok when role attrs are valid", %{attrs: attrs} do
      assert {:ok, %Role{} = role} = Roles.create_role(attrs)

      assert role.id == attrs.id
      assert role.permissions == attrs.permissions
    end

    test "error when role attrs are invalid" do
      attrs = %{id: nil, permissions: :invalid}

      assert {:error, changeset} = Roles.create_role(attrs)
      errors = errors_on(changeset)

      assert %Changeset{valid?: false} = changeset
      assert Enum.member?(errors.id, "can't be blank")
      assert Enum.member?(errors.permissions, "is invalid")
    end

    test "error when role_id already exists", %{attrs: attrs} do
      attrs = Map.put(attrs, :id, insert_role().id)

      assert {:error, changeset} = Roles.create_role(attrs)
      errors = errors_on(changeset)

      assert %Changeset{valid?: false} = changeset
      assert Enum.member?(errors.id, "has already been taken")
    end
  end

  describe "update_role/2 returns" do
    setup [:put_role]

    test "ok when role attrs are valid", %{role: role, attrs: attrs} do
      assert {:ok, role} = Roles.update_role(role, attrs)

      assert attrs.id == role.id
      assert attrs.permissions == role.permissions
    end

    test "error when role attrs are invalid", %{role: role} do
      invalid_attrs = %{id: "@@", permissions: %{}}

      assert {:error, changeset} = Roles.update_role(role, invalid_attrs)
      errors = errors_on(changeset)

      assert %Changeset{valid?: false} = changeset
      assert Enum.member?(errors.id, "has invalid format")
      assert Enum.member?(errors.permissions, "is invalid")
    end
  end

  describe "delete_role/1 returns" do
    setup [:put_role]

    test "ok when role is deleted", %{role: role} do
      assert {:ok, %Role{}} = Roles.delete_role(role)

      assert {:error, changeset} = Roles.delete_role(role)
      errors = errors_on(changeset)

      assert %Changeset{valid?: false} = changeset
      assert Enum.member?(errors.id, "not found")
    end

    test "error when role can't be deleted", %{role: role} do
      Map.new() |> Map.put(:role_id, role.id) |> insert_user()

      assert {:error, changeset} = Roles.delete_role(role)
      errors = errors_on(changeset)

      assert %Changeset{valid?: false} = changeset
      assert Enum.member?(errors.id, "can't be deleted")
    end
  end

  defp put_role(_) do
    {:ok, role: insert_role()}
  end
end
