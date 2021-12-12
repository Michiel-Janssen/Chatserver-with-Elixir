defmodule RootSupervisor.StaticSupervisorChat do
  use Supervisor

  @me __MODULE__

  def start_link(arg) do
    Supervisor.start_link(@me, arg, name: @me)
  end


  def init(_init_arg) do
    children = [
      {RootSupervisor.DynamicSupervisorChat, []},
      {RootSupervisor.ChatroomManager, []}
    ]

    opts = [strategy: :one_for_one]
    Supervisor.init(children, opts)
  end
end
