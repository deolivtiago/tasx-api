defmodule TasxCore.Repo.Migrations.CreateTasks do
  use Ecto.Migration

  def change do
    create table(:tasks, primary_key: false) do
      add :id, :binary_id, primary_key: true

      add :title, :string, null: false, default: ""
      add :description, :text, null: false, default: ""

      add :status, :integer, null: false, default: 0
      add :position, :integer, null: false, default: 0

      add :progress, :integer, null: false, default: 0
      add :tags, {:array, :string}, null: false, default: []

      add :user_id,
          references(:users, on_delete: :delete_all, on_update: :update_all, type: :binary_id),
          null: false

      timestamps(type: :utc_datetime)
    end

    create index(:tokens, [:user_id])
  end
end
