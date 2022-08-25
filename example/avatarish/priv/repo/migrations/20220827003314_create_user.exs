defmodule Avatarish.Repo.Migrations.CreateUserTables do
  use Ecto.Migration

  def change do
    create table(:user, primary_key: false) do
      add :id, :binary_id, primary_key: true

      add :identicon_source, :string
      timestamps(type: :utc_datetime_usec)
    end

    create table(:scim_user, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :user_id, references(:user, on_delete: :delete_all), null: false

      add :data, :map
      timestamps(type: :utc_datetime_usec)
    end
  end
end
