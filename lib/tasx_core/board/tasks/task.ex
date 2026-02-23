defmodule TasxCore.Board.Tasks.Task do
  @moduledoc false
  use Ecto.Schema

  import Ecto.Changeset

  alias TasxCore.Access.Users.User

  @tag_format ~r/^[a-zA-Z0-9_\-\.\|]{,16}+$/

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "tasks" do
    field :title, :string
    field :description, :string, default: ""

    field :status, Ecto.Enum,
      values: [draft: 0, open: 1, pending: 2, doing: 3, done: 4],
      default: :draft

    field :position, :integer, default: 0

    field :progress, :integer, default: 0
    field :tags, {:array, :string}, default: []

    belongs_to :user, User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(task \\ %__MODULE__{}, attrs) when is_map(attrs) do
    required_attrs = ~w(title user_id)a
    optional_attrs = ~w(description status progress position tags)a

    task
    |> cast(attrs, required_attrs ++ optional_attrs)
    |> validate_required(required_attrs)
    |> unique_constraint(:id, name: :tasks_pkey)
    |> validate_length(:title, min: 2, max: 255)
    |> validate_length(:description, max: 4096)
    |> assoc_constraint(:user)
    |> foreign_key_constraint(:user_id)
    |> validate_change(:tags, &validate_array_format/2)
  end

  defp validate_array_format(field, values, pattern \\ @tag_format) do
    if not Enum.all?(values, &String.match?(&1, pattern)),
      do: [{field, "has invalid format"}],
      else: []
  end
end
