defmodule TasxCore.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users, primary_key: false) do
      add :id, :binary_id, primary_key: true

      add :full_name, :string, null: false, default: ""

      add :email, :string, null: false
      add :password, :string, null: false

      add :avatar_url, :string, null: false, default: ""

      add :role_id,
          references(:roles, on_delete: :restrict, on_update: :update_all, type: :string),
          null: false

      add :otp_secret, :binary, null: false
      add :is_verified, :boolean, null: false, default: false

      timestamps(type: :timestamptz)
    end

    create unique_index(:users, [:email])
    create index(:users, [:role_id])
  end
end
