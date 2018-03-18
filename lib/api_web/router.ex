defmodule ApiWeb.Router do
  use ApiWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :json_auth do
    plug :accepts, ["json"]
    plug ApiWeb.Guardian.AuthPipeline
  end

  pipeline :json_api do
    plug :accepts, ["json", "json-api"]
    plug JaSerializer.ContentTypeNegotiation
    plug JaSerializer.Deserializer
  end

  pipeline :json_api_auth do
    plug :accepts, ["json", "json-api"]
    plug ApiWeb.Guardian.AuthPipeline
    plug JaSerializer.ContentTypeNegotiation
    plug JaSerializer.Deserializer
  end

  scope "/api/v1", ApiWeb, as: :api do
    pipe_through :json_auth

    delete "/avatars", AvatarController, :delete
    resources "/avatars", AvatarController, only: [:create]
  end

  scope "/api/v1", ApiWeb, as: :api do
    pipe_through :json_api_auth

    get "/", PageController, :index
    delete "/logout", AuthController, :delete
    resources "/blocks", BlockController, only: [:create, :delete]
    resources "/comments", CommentController, only: [:create, :delete, :index, :show, :update]
    resources "/follows", FollowController, only: [:create, :delete, :index, :update]
    resources "/posts", PostController, only: [:create, :delete, :show, :update]
    resources "/reactions", ReactionController, only: [:create, :delete, :index, :update]
    resources "/search-queries", SearchQueryController, only: [:index]
    resources "/timeline-items", TimelineItemController, only: [:index]
    resources "/users", UserController, only: [:create, :index]
    resources "/user-identities", UserIdentityController, only: [:create, :delete, :update]
    resources "/user-profiles", UserProfileController, only: [:update]
  end

  scope "/api/v1/auth", ApiWeb do
    pipe_through :json_api
    post "/identity/callback", AuthController, :identity_callback
  end
end
