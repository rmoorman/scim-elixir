defmodule Avatarish.Repo.User do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "user" do
    has_one :scim_user, Avatarish.Repo.SCIMUser

    field :identicon_source, :string
    timestamps(type: :utc_datetime_usec)
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:identicon_source])
    |> validate_required([:identicon_source])
  end
end
