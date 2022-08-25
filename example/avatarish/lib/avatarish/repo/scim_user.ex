defmodule Avatarish.Repo.SCIMUser do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "scim_user" do
    belongs_to :user, Avatarish.Repo.User

    field :data, :map
    timestamps(type: :utc_datetime_usec)
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:user_id, :data])
    |> validate_required([:user_id, :data])
  end
end
