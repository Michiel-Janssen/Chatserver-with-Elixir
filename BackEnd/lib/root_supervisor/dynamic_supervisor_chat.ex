defmodule RootSupervisor.DynamicSupervisorChat do
  use DynamicSupervisor

  @me __MODULE__


  ########################################################################
  ##                              START                                 ##
  ########################################################################

  def start_link(arg) do
    DynamicSupervisor.start_link(@me, arg, name: @me)
  end

  @impl true
  def init(_init_arg) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end


  ########################################################################
  ##                            FUNCTIONS                               ##
  ########################################################################

  def add_chatroom_instance(chatroom_id) do
    DynamicSupervisor.start_child(@me, {RootSupervisor.StaticSupervisorChatroom, chatroom_id: chatroom_id})
  end
end
