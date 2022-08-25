defmodule AvatarishWeb.SCIM.UsersEndpointTest do
  use AvatarishWeb.SCIMCase

  describe "GET /Users" do
    test "requires authentication", %{conn_without_auth: conn} do
      conn = get(conn, "/scim/Users")
      assert response(conn, 401) == "Unauthorized"
    end

    test "returns empty list when called with non-existent `userName`", %{conn: conn} do
      conn = get(conn, "/scim/Users")

      assert json_response(conn, 200) == %{
               "schemas" => ["urn:ietf:params:scim:api:messages:2.0:ListResponse"],
               "totalResults" => 0,
               "itemsPerPage" => 50,
               "startIndex" => 1,
               "Resources" => []
             }
    end
  end
end
