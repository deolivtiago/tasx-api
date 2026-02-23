defmodule TasxCore.Repo.Migrations.CreateTokens do
  use Ecto.Migration

  def change do
    create table(:tokens, primary_key: false) do
      add :id, :binary_id, primary_key: true

      add :token, :text, null: false
      add :type, :string, null: false
      add :expires_at, :timestamptz, null: false

      add :user_id,
          references(:users, on_delete: :delete_all, on_update: :update_all, type: :binary_id),
          null: false

      timestamps(type: :utc_datetime, updated_at: false)
    end

    create unique_index(:tokens, [:token])
    create index(:tokens, [:user_id])
  end
end
