defmodule ApiWeb.Router do
  use ApiWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json", "json-api"]
    plug JaSerializer.ContentTypeNegotiation
    plug JaSerializer.Deserializer
  end

  scope "/", ApiWeb, as: :api do
    pipe_through :api # Use the default browser stack

    get "/", PageController, :index
    resources "/users", UserController, only: [:show]
    resources "/follows", FollowController, only: [:index, :show]
  end

  # Other scopes may use custom stacks.
  # scope "/api", ApiWeb do
  #   pipe_through :api
  # end
end
