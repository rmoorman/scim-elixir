defmodule AvatarishWeb.PageController do
  use AvatarishWeb, :controller

  alias Avatarish.Users

  def index(conn, _params) do
    user_list = Users.list()

    conn
    |> assign(:user_list, user_list)
    |> render("index.html")
  end
end
