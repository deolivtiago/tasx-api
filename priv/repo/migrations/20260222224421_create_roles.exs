defmodule TasxCore.Repo.Migrations.CreateRoles do
  use Ecto.Migration

  def change do
    create table(:roles, primary_key: false) do
      add :id, :string, primary_key: true

      add :permissions, {:array, :string}, null: false, default: []

      timestamps(type: :timestamptz)
    end
  end
end
