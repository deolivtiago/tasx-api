defmodule TasxWeb.Router do
  use TasxWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :auth do
    plug TasxWeb.AuthenticationPlug
    plug TasxWeb.AuthorizationPlug
  end

  scope "/api", TasxWeb do
    pipe_through :api

    post "/auth/sign-up", AuthController, :sign_up
    post "/auth/sign-in", AuthController, :sign_in
    get "/auth/send-code", AuthController, :send_code
    post "/auth/confirm-account", AuthController, :confirm_account
    post "/auth/reset-password", AuthController, :reset_password
    post "/auth/change-email", AuthController, :change_email
    post "/auth/change-password", AuthController, :change_password
    post "/auth/refresh-token", AuthController, :refresh_token
    delete "/auth/sign-out", AuthController, :sign_out
  end

  scope "/api", TasxWeb do
    pipe_through [:api, :auth]

    get "/auth/user-info", AuthController, :user_info

    resources "/tasks", TaskController, except: [:new, :edit]
  end

  # Enable Swoosh mailbox preview in development
  if Application.compile_env(:tasx, :dev_routes) do
    scope "/dev" do
      pipe_through [:fetch_session, :protect_from_forgery]

      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
