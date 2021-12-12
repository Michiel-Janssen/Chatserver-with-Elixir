defmodule FrontEndChatserverWeb.Router do
  use FrontEndChatserverWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end


  scope "/", FrontEndChatserverWeb do
    pipe_through :browser

    get "/", PageController, :index
    get "/loading", PageController, :loading
    get "/new/client", PageController, :new_client
    get "/new/chatroom", PageController, :new_chatroom
    get "/new/participate", PageController, :new_participate
    get "/new/sendmessage", PageController, :new_sendmessage
    get "/all/chatrooms", PageController, :overview_chatrooms
    get "/all/messages", PageController, :overview_messages
  end


  scope "/api", FrontEndChatserverWeb do
    pipe_through :api

    get "/logs/short", PageController, :logs_short
    get "/logs/full", PageController, :logs_full

    get "/create/client/:client_id", PageController, :create_client
    get "/create/chatroom/:chatroom_id", PageController, :create_chatroom

    get "/all/clients", PageController, :all_clients
    get "/all/chatrooms", PageController, :all_chatrooms

    get "/all/messages/:chatroom_id", PageController, :all_messages

    get "/participate/:chatroom_id/:client_id", PageController, :participate_chatroom
    get "/sendmessage/:chatroom_id/:client_id/:message", PageController, :send_message_in_chatroom

  end



  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through :browser
      live_dashboard "/dashboard", metrics: FrontEndChatserverWeb.Telemetry
    end
  end
end
