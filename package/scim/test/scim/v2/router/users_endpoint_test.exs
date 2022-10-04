defmodule SCIM.V2.Router.UsersEndpointTest do
  use SCIM.V2.RouterCase, async: true

  defmodule Impl do
    use SCIM.V2.Adapter

    def list_users(_conn), do: get_users()

    @users {__MODULE__, :users}
    def set_users(data), do: KV.set(@users, data)
    def get_users(), do: KV.get(@users, [])
  end

  test "GET /Users returns empty list when called with non-existent `userName`" do
    Impl.set_users([])

    conn =
      conn(:get, "/Users", %{filter: ~s(username eq "foo")})
      |> route(Impl)

    assert %{"Resources" => []} = json_response(conn, 200)
  end
end
