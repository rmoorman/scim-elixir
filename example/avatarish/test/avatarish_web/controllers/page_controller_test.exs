defmodule AvatarishWeb.PageControllerTest do
  use AvatarishWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, "/")
    assert html_response(conn, 200) =~ "SCIM attribute"
  end
end
