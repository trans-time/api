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

  pipeline :api_auth do
    plug :accepts, ["json", "json-api"]
    plug ApiWeb.Guardian.AuthPipeline
    plug JaSerializer.ContentTypeNegotiation
    plug JaSerializer.Deserializer
  end

  scope "/api/v1", ApiWeb, as: :api do
    pipe_through :api_auth

    get "/", PageController, :index
    delete "/logout", AuthController, :delete
    resources "/comments", CommentController, only: [:index, :show]
    resources "/follows", FollowController, only: [:create, :delete, :index, :update]
    resources "/posts", PostController, only: [:show]
    resources "/reactions", ReactionController, only: [:index]
    resources "/search-queries", SearchQueryController, only: [:index]
    resources "/timeline-items", TimelineItemController, only: [:index]
    resources "/users", UserController, only: [:create, :show]
  end

  scope "/api/v1/auth", ApiWeb do
    pipe_through :api
    post "/identity/callback", AuthController, :identity_callback
  end
end
