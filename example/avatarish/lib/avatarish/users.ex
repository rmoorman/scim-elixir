defmodule Avatarish.Users do
  alias Avatarish.Repo
  alias Avatarish.Repo.{User, SCIMUser}

  def list() do
    Repo.all(Repo.User)
  end

  def get(id) when is_binary(id) do
    Repo.get(User, id)
  end
end
