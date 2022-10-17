ExUnit.start()

defmodule SCIM.TestRepo do
  use Ecto.Repo,
    otp_app: :scim,
    adapter: Ecto.Adapters.SQLite3
end

{:ok, _} = SCIM.TestRepo.start_link()

Ecto.Adapters.SQL.Sandbox.mode(SCIM.TestRepo, :manual)
