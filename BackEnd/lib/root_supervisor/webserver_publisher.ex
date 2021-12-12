defmodule RootSupervisor.WebserverPublisher do
  use GenServer
  require IEx
  require Logger

  @channel :webserver_channel
  @exchange "webserver-exchange"
  @queue "webserver-replies"

  @me __MODULE__

  @enforce_keys [:channel]
  defstruct [:channel]

  ########################################################################
  ##                                API                                 ##
  ########################################################################

  def start_link(_args \\ []), do: GenServer.start_link(@me, :no_opts, name: @me)

  def send_message(payload), do: GenServer.call(@me, {:send_message, payload})

  def all_chatrooms(), do: GenServer.call(@me, {:all_chatrooms})

  def all_messages(chatroom_id), do: GenServer.call(@me, {:all_messages, chatroom_id})


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
  def handle_call({:send_message, payload}, _, %@me{channel: c} = state) when is_map(payload) do
    payload = Jason.encode!(payload)
    :ok = AMQP.Basic.publish(c, @exchange, "", payload)
    {:reply, :ok, state}
  end





  @impl true
  def handle_call({:all_chatrooms}, _, %@me{channel: c} = state) do
    unique_tag = :erlang.make_ref() |> Kernel.inspect()
    data = RootSupervisor.ChatroomManager.all_chatrooms()

    payload = Jason.encode!(%{command: :all_chatrooms, data: data, unique_tag: unique_tag})
    :ok = AMQP.Basic.publish(c, @exchange, @queue, payload)
    {:reply, unique_tag, state}
  end

  @impl true
  def handle_call({:all_messages, chatroom_id}, _, %@me{channel: c} = state) do
    unique_tag = :erlang.make_ref() |> Kernel.inspect()
    data = RootSupervisor.ChatroomManager.all_messages(chatroom_id)
    IO.inspect(data)

    # Data moet in een ander formaat komen.

    payload = Jason.encode!(%{command: :all_messages, data: data, unique_tag: unique_tag})
    IO.inspect(payload)
    :ok = AMQP.Basic.publish(c, @exchange, @queue, payload)
    {:reply, unique_tag, state}
  end







  @impl true
  def handle_call({:all_clients}, _, %@me{channel: c} = state) do
    unique_tag = :erlang.make_ref() |> Kernel.inspect()

    # effe size van gemaakt om te zien of ik shit kan doorgeven gemakkelijker
    data = RootSupervisor.ChatroomManager.all_clients()
    size = Enum.count(data)

    payload = Jason.encode!(%{command: :all_clients, data: size, unique_tag: unique_tag})
    :ok = AMQP.Basic.publish(c, @exchange, @queue, payload)
    {:reply, unique_tag, state}
  end


  ########################################################################
  ##                          HELPER FUNCTIONS                          ##
  ########################################################################

  defp rabbitmq_setup(%@me{} = state) do
    :ok = AMQP.Exchange.declare(state.channel, @exchange, :fanout)
    #{:ok, _consumer_and_msg_info} = AMQP.Queue.declare(state.channel, @queue)
    #:ok = AMQP.Queue.bind(state.channel, @queue, @exchange, routing_key: @queue)
  end
end
