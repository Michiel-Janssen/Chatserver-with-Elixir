defmodule FrontEndChatserver.ChatroomPublisher do
  use GenServer
  require IEx
  require Logger

  @channel :chatroom_channel
  @exchange "chatroom-exchange"
  @queue "manager-operations"

  @me __MODULE__

  @enforce_keys [:channel]
  defstruct [:channel]

  ########################################################################
  ##                               API                                  ##
  ########################################################################

  def start_link(_args \\ []), do: GenServer.start_link(@me, :no_opts, name: @me)
  def create_chatroom(chatroom_id), do: GenServer.call(@me, {:create_chatroom, chatroom_id})

  def all_chatrooms(), do: GenServer.call(@me, {:all_chatrooms})

  def all_messages(chatroom_id), do: GenServer.call(@me, {:all_messages, chatroom_id})

  def participate_chatroom(chatroom_id, client_id), do: GenServer.call(@me, {:participate_chatroom, chatroom_id, client_id})

  def send_message_in_chatroom(chatroom_id, client_id, message), do: GenServer.call(@me, {:send_message_in_chatroom, chatroom_id, client_id, message})


  ########################################################################
  ##                             CALLBACKS                              ##
  ########################################################################

  @impl true
  def init(:no_opts) do
    {:ok, amqp_channel} = AMQP.Application.get_channel(@channel)
    state = %@me{channel: amqp_channel}
    rabbitmq_setup(state)

    {:ok, state}
  end


  ########################################################################
  ##                            HANDLE CALL                             ##
  ########################################################################

  @impl true
  def handle_call({:create_chatroom, chatroom_id}, _, %@me{channel: c} = state) do
    unique_tag = :erlang.make_ref() |> Kernel.inspect()
    payload = Jason.encode!(%{command: "create", chatroom_id: chatroom_id, unique_tag: unique_tag})
    :ok = AMQP.Basic.publish(c, @exchange, @queue, payload)
    {:reply, unique_tag, state}
  end




  @impl true
  def handle_call({:all_chatrooms}, _, %@me{channel: c} = state) do
    unique_tag = :erlang.make_ref() |> Kernel.inspect()
    payload = Jason.encode!(%{command: "all_chatrooms", unique_tag: unique_tag})
    :ok = AMQP.Basic.publish(c, @exchange, @queue, payload)
    {:reply, unique_tag, state}
  end

  @impl true
  def handle_call({:all_messages, chatroom_id}, _, %@me{channel: c} = state) do
    unique_tag = :erlang.make_ref() |> Kernel.inspect()
    payload = Jason.encode!(%{command: "all_messages", chatroom_id: chatroom_id, unique_tag: unique_tag})
    :ok = AMQP.Basic.publish(c, @exchange, @queue, payload)
    {:reply, unique_tag, state}
  end






  @impl true
  def handle_call({:participate_chatroom, chatroom_id, client_id}, _, %@me{channel: c} = state) do
    unique_tag = :erlang.make_ref() |> Kernel.inspect()
    payload = Jason.encode!(%{command: "participate_chatroom", chatroom_id: chatroom_id, client_id: client_id, unique_tag: unique_tag})
    :ok = AMQP.Basic.publish(c, @exchange, @queue, payload)
    {:reply, unique_tag, state}
  end

  @impl true
  def handle_call({:send_message_in_chatroom, chatroom_id, client_id, message}, _, %@me{channel: c} = state) do
    unique_tag = :erlang.make_ref() |> Kernel.inspect()
    payload = Jason.encode!(%{command: "send_message_in_chatroom", chatroom_id: chatroom_id, client_id: client_id, message: message, unique_tag: unique_tag})
    :ok = AMQP.Basic.publish(c, @exchange, @queue, payload)
    {:reply, unique_tag, state}
  end


  ########################################################################
  ##                          HELPER FUNCTIONS                          ##
  ########################################################################

  defp rabbitmq_setup(%@me{} = state) do
    # Create exchange, queue and bind them.
    :ok = AMQP.Exchange.declare(state.channel, @exchange, :direct)
    {:ok, _consumer_and_msg_info} = AMQP.Queue.declare(state.channel, @queue)
    :ok = AMQP.Queue.bind(state.channel, @queue, @exchange, routing_key: @queue)
  end

end
