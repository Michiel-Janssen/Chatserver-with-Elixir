defmodule FrontEndChatserver.Application do
  use Application


  ########################################################################
  ##                               START                                ##
  ########################################################################

  def start(_type, _args) do
    children = [
      FrontEndChatserverWeb.Telemetry,
      {Phoenix.PubSub, name: FrontEndChatserver.PubSub},
      FrontEndChatserverWeb.Endpoint,
      FrontEndChatserver.ChatroomPublisher,
      FrontEndChatserver.ClientPublisher,
      FrontEndChatserver.LogDatabase,
      FrontEndChatserver.WebserverConsumer
    ]

    opts = [strategy: :one_for_one, name: FrontEndChatserver.Supervisor]
    Supervisor.start_link(children, opts)
  end


  ########################################################################
  ##                               CONFIG                               ##
  ########################################################################

  def config_change(changed, _new, removed) do
    FrontEndChatserverWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
