defmodule AvatarishWeb.AvatarController do
  use AvatarishWeb, :controller

  alias Avatarish.Users

  action_fallback AvatarishWeb.FallbackController

  def image(conn, params) do
    with(
      %{"user" => user_id} <- params,
      %{identicon_source: "" <> _ = source} <- Users.get(user_id),
      "" <> _ = image <- Idicon.create(source)
    ) do
      conn
      |> put_resp_content_type("image/svg+xml")
      |> text(image)
    else
      _ -> {:error, :not_found}
    end
  end
end
