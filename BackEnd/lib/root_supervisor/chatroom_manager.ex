defmodule RootSupervisor.ChatroomManager do
  use GenServer

  require Logger

  @me __MODULE__
  defstruct chatrooms: %{}


  ########################################################################
  ##                               API                                  ##
  ########################################################################

  def start_link(args) do
    GenServer.start_link(@me, args, name: @me)
  end

  def add_chatroom(chatroom_id) do
    GenServer.call(@me, {:create_chatroom, chatroom_id})
  end

  def all_chatrooms() do
    GenServer.call(@me, :all_chatrooms)
  end

  def all_messages(chatroom_id) do
    GenServer.call(@me, {:all_messages, chatroom_id})
  end


  def participate_chatroom(chatroom_id, client_id) do
    GenServer.call(@me, {:participate_chatroom, chatroom_id, client_id})
  end

  def send_message_in_chatroom(chatroom_id, client_id, message) do
    GenServer.call(@me, {:send_message_in_chatroom, chatroom_id, client_id, message})
  end


  ########################################################################
  ##                             CALLBACKS                              ##
  ########################################################################

  @impl true
  def init(_args), do: {:ok, %@me{}}


  ########################################################################
  ##                            HANDLE CALL                             ##
  ########################################################################

  @impl true
  def handle_call({:create_chatroom, chatroom_id}, _from, %@me{} = state) do
    ## Case schrijven als chatroom_id empty is ##
    case Map.has_key?(state.chatrooms, chatroom_id) do
      true ->
        {:reply, {:error, :already_exist}, state}

      false ->
        #The standard dynamicsupervisor starts a child (staticsupervisorchatroom) on our dynamicsupervisorchat with child spec staticsupervisorchatroom and chatroomid
        response = DynamicSupervisor.start_child(RootSupervisor.DynamicSupervisorChat, {RootSupervisor.StaticSupervisorChatroom, [chatroom_id: chatroom_id]})
        case response do
          {:ok, pid} ->
            new_chatrooms = Map.put_new(state.chatrooms, chatroom_id, pid)
            newstate = %{state | chatrooms: new_chatrooms}
            {:reply, response, newstate}
          {:error, message} ->
            {:reply, message}
        end
      end
  end




  @impl true
  def handle_call(:all_chatrooms, _from, state) do
    chatrooms = state.chatrooms
    keys = Map.keys(chatrooms)
    {:reply, keys, state}
  end

  @impl true
  def handle_call({:all_messages, chatroom_id}, _from, state) do
    response = RootSupervisor.Chatroom.all_messages(chatroom_id)
    {:reply, response, state}
  end






  def handle_call({:participate_chatroom, chatroom_id, client_id}, _from, %@me{} = state) do
    response = RootSupervisor.Chatroom.participate_chatroom(chatroom_id, client_id)
    {:reply, response, state}
  end

  def handle_call({:send_message_in_chatroom, chatroom_id, client_id, message}, _from, %@me{} = state) do
    response = RootSupervisor.Chatroom.send_message_in_chatroom(chatroom_id, client_id, message)
    {:reply, response, state}
  end

end
