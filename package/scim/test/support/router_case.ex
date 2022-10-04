defmodule SCIM.V2.RouterCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      use Plug.Test
      import Plug.Conn
      import SCIM.V2.RouterCase

      # FIXME: is there a better alternative that does not require phoenix?
      import Phoenix.ConnTest, only: [json_response: 2]

      import SCIM.V2.TestHelpers

      alias SCIM.V2.RouterCase.KV
    end
  end

  alias SCIM.V2.Router

  def route(conn, impl) do
    Router.call(conn, Router.init(impl: impl, json_library: Jason))
  end

  defmodule KV do
    def set(key, data), do: Process.put({__MODULE__, key}, data)
    def get(key, default \\ nil)
    def get(key, default), do: Process.get({__MODULE__, key}, default)
  end
end
