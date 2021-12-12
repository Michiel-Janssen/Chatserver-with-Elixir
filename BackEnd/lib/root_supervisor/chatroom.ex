defmodule RootSupervisor.Chatroom do
  use GenServer

  require Logger

  @enforce_keys [:chatroom]
  defstruct messages: [], participants: [], chatroom: nil

  @me __MODULE__


  ########################################################################
  ##                               API                                  ##
  ########################################################################

  def start_link(args) do
    case args[:chatroom_id] do
      nil -> {:error, {:missing_arg, :chatroom_id}}
      #via_tuple(args[:chatroom_id])
      #chatroom_id -> GenServer.start_link(@me, args, name: String.to_atom(chatroom_id))
      chatroom_id -> GenServer.start_link(@me, args, name: via_tuple(args[:chatroom_id]))
    end
  end

  def send_message_in_chatroom(chatroom_id, client_id, message) do
    GenServer.call(via_tuple(chatroom_id), {:send_message_in_chatroom, client_id, message})
  end

  def participate_chatroom(chatroom_id, client_id) do
    GenServer.call(via_tuple(chatroom_id), {:participate, client_id})
  end

  def all_messages(chatroom_id) do
    GenServer.call(via_tuple(chatroom_id), {:all_messages})
  end


  ########################################################################
  ##                             CALLBACKS                              ##
  ########################################################################

  @impl true
  def init(args) do
    {:ok, %@me{chatroom: args[:chatroom_id]}}
  end


  ########################################################################
  ##                            HANDLE CALL                             ##
  ########################################################################

  @impl true
  def handle_call({:participate, client_id}, _, %@me{participants: ps} = state) do
    with {:registered?, name} when not is_nil(name) <- {:registered?, client_id},
          {:participating?, false} <- {:participating?, name in ps} do
              new_state = %{state | participants: [name | state.participants]}
              IO.inspect(new_state)
              {:reply, :ok, new_state}
    else
      error ->
        {:reply, error, state}
     end
  end

  @impl true
  def handle_call({:send_message_in_chatroom, client_id, message}, _, %@me{participants: ps} =state) do
    case client_id in ps do
      true ->
        new_state = %{state | messages:  [message | state.messages]}
        IO.inspect(new_state)
        {:reply, :ok, new_state}
      false ->
        {:reply, {:error, :not_a_client}, state}
    end
  end

  @impl true
  def handle_call({:all_messages}, _, %@me{messages: ms} = state) do
    {:reply, ms, state}
  end


  ########################################################################
  ##                          HELPER FUNCTIONS                          ##
  ########################################################################

  defp retrieve_sender_name(pid) when is_pid(pid) do
    case Registry.keys(Registry.ChatRegistry, pid) do
      [] -> nil
      [sender] -> sender
    end
  end

  defp create_msg_entry(client_id, message) do
    #timestamp = DateTime.utc_now()
    {message}
  end

  defp via_tuple(chatroom_id) do
    {:via, Registry, {Registry.ChatRegistry, {:chatroom, chatroom_id}}}
  end

end
