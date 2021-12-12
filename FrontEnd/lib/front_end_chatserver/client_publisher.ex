defmodule FrontEndChatserver.ClientPublisher do
  use GenServer
  require IEx
  require Logger

  @channel :client_channel
  @exchange "client-exchange"
  @queue "client-operations"

  @me __MODULE__

  @enforce_keys [:channel]
  defstruct [:channel]


  ########################################################################
  ##                               API                                  ##
  ########################################################################

  def start_link(_args \\ []), do: GenServer.start_link(@me, :no_opts, name: @me)
  def create_client(client_id), do: GenServer.call(@me, {:create_client, client_id})


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
  def handle_call({:create_client, client_id}, _, %@me{channel: c} = state) do
    unique_tag = :erlang.make_ref() |> Kernel.inspect()
    payload = Jason.encode!(%{command: "create", client_id: client_id, unique_tag: unique_tag})
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
