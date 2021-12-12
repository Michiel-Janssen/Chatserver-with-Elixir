defmodule RootSupervisor.StaticSupervisorChatroom do
  use Supervisor

  @me __MODULE__

  def start_link(arg) do

    case arg[:chatroom_id] do
       nil ->
          {:error, {:missing_arg, :chatroom_id}}
       chatroom_id ->
          via_tuple = {:via, Registry, {Registry.ChatRegistry, chatroom_id}}
          Supervisor.start_link(@me, arg, name: via_tuple)
    end
  end


  def init(init_arg) do
    children = [
      {RootSupervisor.Chatroom, init_arg}
    ]

    opts = [strategy: :rest_for_one]
    Supervisor.init(children, opts)
  end

end
