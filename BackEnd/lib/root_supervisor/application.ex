defmodule RootSupervisor.Application do
  use Application

  ########################################################################
  ##                         ROOT SUPERVISOR                            ##
  ########################################################################
  def start(_type, _args) do
    children = [
      {Registry, keys: :unique, name: Registry.ChatRegistry},
      {RootSupervisor.DynamicSupervisorClient, []},
      {RootSupervisor.StaticSupervisorChat, []},
      RootSupervisor.WebserverPublisher,
      RootSupervisor.ClientConsumer,
      RootSupervisor.ManagerOperationsConsumer
    ]

    opts = [strategy: :one_for_one, name: RootSupervisor.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
