defmodule TasxCore.Access.Roles.RoleTest do
  use TasxCore.DataCase, async: true

  import TasxCore.Access.RoleFixtures

  alias Ecto.Changeset
  alias TasxCore.Access.Roles.Role

  setup do
    {:ok, attrs: role_attrs()}
  end

  describe "changeset/1 returns a valid changeset" do
    test "when id is valid", %{attrs: attrs} do
      changeset = Role.changeset(attrs)

      assert %Changeset{valid?: true} = changeset
      assert Changeset.get_field(changeset, :id) == attrs.id
    end

    test "when permissions are valid", %{attrs: attrs} do
      changeset = Role.changeset(attrs)

      assert %Changeset{valid?: true} = changeset
      assert Changeset.get_field(changeset, :permissions) == attrs.permissions
    end
  end

  describe "changeset/1 returns an invalid changeset" do
    test "when id is empty", %{attrs: attrs} do
      attrs = Map.put(attrs, :id, nil)

      changeset = Role.changeset(attrs)
      errors = errors_on(changeset)

      assert %Changeset{valid?: false} = changeset
      assert Enum.member?(errors.id, "can't be blank")
    end

    test "when id has invalid format", %{attrs: attrs} do
      attrs = Map.put(attrs, :id, "@@")

      changeset = Role.changeset(attrs)
      errors = errors_on(changeset)

      assert %Changeset{valid?: false} = changeset
      assert Enum.member?(errors.id, "has invalid format")
    end

    test "when id is invalid", %{attrs: attrs} do
      attrs = Map.put(attrs, :id, :invalid)

      changeset = Role.changeset(attrs)
      errors = errors_on(changeset)

      assert %Changeset{valid?: false} = changeset
      assert Enum.member?(errors.id, "is invalid")
    end

    test "when permissions is invalid", %{attrs: attrs} do
      attrs = Map.put(attrs, :permissions, "@@")

      changeset = Role.changeset(attrs)
      errors = errors_on(changeset)

      assert %Changeset{valid?: false} = changeset
      assert Enum.member?(errors.permissions, "is invalid")
    end

    test "when permissions has invalid format", %{attrs: attrs} do
      attrs = Map.put(attrs, :permissions, ["@@"])

      changeset = Role.changeset(attrs)
      errors = errors_on(changeset)

      assert %Changeset{valid?: false} = changeset
      assert Enum.member?(errors.permissions, "has invalid format")
    end
  end
end
