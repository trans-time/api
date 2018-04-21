defmodule ApiWeb.Guardian.AuthPipeline do
  use Guardian.Plug.Pipeline, otp_app: :api,
                              module: Api.Accounts.Guardian,
                              error_handler: ApiWeb.Guardian.AuthErrorHandler

  plug Guardian.Plug.VerifyHeader, realm: "Bearer"
  plug Guardian.Plug.LoadResource, allow_blank: true
  plug ApiWeb.Plugs.IsNotBanned
end
