defmodule SCIM.V2.Router do
  use Plug.Router, copy_opts_to_assign: :opts
  import SCIM.V2.Response
  import SCIM.V2.Filter

  if Mix.env() == :dev do
    use Plug.Debugger
  end

  use Plug.ErrorHandler

  plug :match
  plug :dispatch

  get "/Users" do
    list = impl(conn, :list_users)
    list_response(conn, list)
  end

  # FIXME: let adapter determine response through helpers?
  # FIXME: support different data sources/return values from the implementation
  #        scrivener? paginator? some not yet existing resultset lib?
  #        maybe a protocol? maybe something like absinthe connection's
  #        from_query/from_list/from_slice?
  # get "/Users", do: impl(conn, :list_users)

  post "/Users" do
    list_response(conn, [])
  end

  match _ do
    send_resp(conn, 404, "Not found")
  end

  defp handle_errors(conn, %{kind: _kind, reason: _reason, stack: _stack}) do
    send_resp(conn, conn.status, "Something went wrong")
  end

  defp impl(conn, function, arguments \\ [])

  defp impl(conn, function, arguments) do
    apply(impl(conn), function, [conn | arguments])
  end

  defp impl(conn) do
    Keyword.fetch!(conn.assigns.opts, :impl)
  end
end
