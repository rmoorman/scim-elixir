defmodule AvatarishWeb.Router do
  use AvatarishWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {AvatarishWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", AvatarishWeb do
    pipe_through :browser

    get "/", PageController, :index
    get "/avatar/:user", AvatarController, :image
  end

  pipeline :scim do
    plug AvatarishWeb.SCIMAuth
  end

  scope "/" do
    pipe_through :scim

    forward "/scim", AvatarishWeb.SCIM
  end

  # Other scopes may use custom stacks.
  # scope "/api", AvatarishWeb do
  #   pipe_through :api
  # end
end
