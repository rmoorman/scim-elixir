defmodule SCIM.V2.Adapter do
  defmacro __using__(_opts) do
    quote do
      @behaviour SCIM.V2.Adapter
    end
  end

  @callback list_users(conn :: Plug.Conn) :: Plug.Conn
  # @callback create_user(conn :: Plug.Conn) :: Plug.Conn
  # @callback retrieve_user(conn :: Plug.Conn) :: Plug.Conn
  # @callback update_user(conn :: Plug.Conn) :: Plug.Conn
  # @callback delete_user(conn :: Plug.Conn) :: Plug.Conn
end
