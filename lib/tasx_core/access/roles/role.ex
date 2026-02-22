defmodule TasxCore.Access.Roles.Role do
  @moduledoc false
  use Ecto.Schema

  import Ecto.Changeset

  @permission_format ~r/^(GET|POST|PUT|DELETE):([a-z0-9][\-\/]?)+$/

  @primary_key {:id, :string, autogenerate: false}
  @foreign_key_type :binary_id

  schema "roles" do
    field :permissions, {:array, :string}, default: []

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(role \\ %__MODULE__{}, attrs) when is_map(attrs) do
    required_attrs = ~w(id)a
    optional_attrs = ~w(permissions)a

    role
    |> cast(attrs, required_attrs ++ optional_attrs)
    |> validate_required(required_attrs)
    |> unique_constraint(:id, name: :roles_pkey)
    |> validate_format(:id, ~r/^[a-zA-Z0-9_]+$/)
    |> validate_length(:id, max: 64)
    |> validate_exclusion(:id, ~w(root), message: "is invalid")
    |> validate_change(:permissions, &validate_array_format/2)
  end

  defp validate_array_format(field, values, pattern \\ @permission_format) do
    if not Enum.all?(values, &String.match?(&1, pattern)),
      do: [{field, "has invalid format"}],
      else: []
  end
end
