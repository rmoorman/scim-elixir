defmodule SCIM.V2.Phoenix.Plug do
  defmacro __using__(opts) do
    quote do
      use SCIM.V2.Adapter
      alias SCIM.V2.Phoenix.Plug.Forwarder
      # import SCIM.V2.Filter

      def init(_) do
        impl = Keyword.get(unquote(opts), :impl, __MODULE__)
        Forwarder.init(impl: impl)
      end

      def call(conn, opts) do
        Forwarder.call(conn, opts)
      end
    end
  end

  defmodule Forwarder do
    use Plug.Builder

    @json_library Phoenix.json_library()

    plug(Plug.Parsers,
      parsers: [:json],
      pass: ["application/json"],
      json_decoder: @json_library
    )

    def call(conn, opts) do
      opts = Keyword.put(opts, :json_library, @json_library)

      conn
      |> super(opts)
      |> Plug.forward(conn.path_info, SCIM.V2.Router, opts)
    end
  end
end
