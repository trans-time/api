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

  pipeline :json_api_moderator_auth do
    plug :accepts, ["json", "json-api"]
    plug ApiWeb.Guardian.ModeratorAuthPipeline
    plug JaSerializer.ContentTypeNegotiation
    plug JaSerializer.Deserializer
  end

  scope "/api/v1", ApiWeb, as: :api do
    pipe_through :json_auth

    delete "/avatars", AvatarController, :delete
    post "/avatars", AvatarController, :create

    post "/images/:image_id/files", ImageFileController, :create
  end

  scope "/api/v1", ApiWeb, as: :api do
    pipe_through :json_api_auth

    get "/", PageController, :index
    delete "/logout", AuthController, :delete
    resources "/blocks", BlockController, only: [:create, :delete]
    resources "/comments", CommentController, only: [:create, :delete, :index, :show, :update]
    resources "/email-changes", EmailChangeController, only: [:create]
    resources "/flags", FlagController, only: [:create, :index, :show]
    resources "/follows", FollowController, only: [:create, :delete, :index, :update]
    resources "/images", ImageController, only: [:create, :delete, :update]
    resources "/posts", PostController, only: [:create, :delete, :show, :update]
    resources "/notifications", NotificationController, only: [:index, :update]
    resources "/reactions", ReactionController, only: [:create, :delete, :index, :update]
    resources "/search-queries", SearchQueryController, only: [:index]
    resources "/tags", TagController, only: [:index]
    resources "/timeline-items", TimelineItemController, only: [:index, :show]
    resources "/users", UserController, only: [:create, :index]
    resources "/user-identities", UserIdentityController, only: [:create, :delete, :update]
    resources "/user-profiles", UserProfileController, only: [:index, :update]
    resources "/user-tag-summaries", UserTagSummaryController, only: [:index]
  end

  scope "/api/v1", ApiWeb, as: :api do
    pipe_through :json_api_moderator_auth
    resources "/moderation-reports", ModerationReportController, only: [:index, :show]
    resources "/verdicts", VerdictController, only: [:create]
  end

  scope "/api/v1/auth", ApiWeb do
    pipe_through :json_api
    post "/identity/callback", AuthController, :identity_callback
  end
end
