defmodule AvatarishWeb.FallbackController do
  use AvatarishWeb, :controller

  def call(conn, {:error, :not_found}) do
    conn
    |> text("""
    The Web site you seek
    cannot be located but
    endless more exist.
    """)
  end

  def call(conn, _) do
    call(conn, {:error, :not_found})
  end
end
