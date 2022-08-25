defmodule AvatarishWeb.SCIMCase do
  @moduledoc """
  This module defines the test case to be used by
  tests that relate to SCIM.
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      # Import conveniences for testing with connections
      import Plug.Conn
      import Phoenix.ConnTest
      import AvatarishWeb.ConnCase

      # The default endpoint for testing
      @endpoint AvatarishWeb.Endpoint
    end
  end

  setup tags do
    Avatarish.DataCase.setup_sandbox(tags)
    conn_without_auth = Phoenix.ConnTest.build_conn()
    conn = auth(conn_without_auth)
    {:ok, conn: conn, conn_without_auth: conn_without_auth}
  end

  defp auth(conn) do
    authorization = Application.fetch_env!(:avatarish, :scim_auth_header)
    Plug.Conn.put_req_header(conn, "authorization", authorization)
  end
end
