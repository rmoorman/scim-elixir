defmodule SCIM.V2.Response do
  import Plug.Conn

  def list_response(conn, data) do
    json_resp(conn, 200, %{
      "Resources" => data,
      "itemsPerPage" => 50,
      "schemas" => ["urn:ietf:params:scim:api:messages:2.0:ListResponse"],
      "startIndex" => 1,
      "totalResults" => 0
    })
  end

  defp json_resp(conn, status, data) do
    encoded = json_encode(conn, data)

    conn
    |> put_resp_content_type("application/json")
    |> resp(status, encoded)
  end

  defp json_encode(conn, data) do
    json_lib(conn).encode!(data)
  end

  defp json_lib(%{assigns: %{opts: opts}}) do
    Keyword.fetch!(opts, :json_library)
  end
end
