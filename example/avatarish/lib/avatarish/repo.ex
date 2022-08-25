defmodule Avatarish.Repo do
  use Ecto.Repo,
    otp_app: :avatarish,
    adapter: Ecto.Adapters.SQLite3
end
