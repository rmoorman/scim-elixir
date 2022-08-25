defmodule AvatarishWeb.SCIMAuth do
  use Plug.Builder

  def call(conn, _) do
    with(
      [auth_header] <- get_req_header(conn, "authorization"),
      {:ok, ^auth_header} <- Application.fetch_env(:avatarish, :scim_auth_header)
    ) do
      conn
    else
      _ -> auth_error(conn)
    end
  end

  defp auth_error(conn) do
    conn
    |> put_resp_content_type("text/plain")
    |> send_resp(401, "Unauthorized")
    |> halt()
  end
end
