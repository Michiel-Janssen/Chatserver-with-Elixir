defmodule FrontEndChatserver.WebserverConsumer do
  use GenServer
  use AMQP

  @channel :webserver_channel
  @exchange "webserver-exchange"
  #@queue "webserver-replies"
  @me __MODULE__

  @enforce_keys [:channel]
  defstruct [:channel]


  ########################################################################
  ##                               API                                  ##
  ########################################################################

  def start_link(args \\ []), do: GenServer.start_link(@me, args, name: @me)

  def init(_opts) do
    {:ok, amqp_channel} = AMQP.Application.get_channel(@channel)
    state = %@me{channel: amqp_channel}
    rabbitmq_setup(state)
    {:ok, state}
  end


  ########################################################################
  ##                            HANDLE INFO                             ##
  ########################################################################

  # Confirmation sent by the broker after registering this process as a consumer
  def handle_info({:basic_consume_ok, %{consumer_tag: _consumer_tag}}, %@me{} = state) do
    # do nothing
    {:noreply, state}
  end

  # Sent by the broker when the consumer is unexpectedly cancelled (such as after a queue deletion)
  def handle_info({:basic_cancel, %{consumer_tag: _consumer_tag}}, %@me{} = state) do
    # do nothing
    {:stop, :normal, state}
  end

  # Confirmation sent by the broker to the consumer process after a Basic.cancel
  def handle_info({:basic_cancel_ok, %{consumer_tag: _consumer_tag}}, %@me{} = state) do
    # do nothing
    {:noreply, state}
  end

  def handle_info({:basic_deliver, payload, meta_info}, %@me{} = state) do
    payload
    |> Jason.decode!()
    |> process_message(meta_info.delivery_tag, state)

    {:noreply, %@me{} = state}
  end


  ########################################################################
  ##                          HELPER FUNCTIONS                          ##
  ########################################################################

  defp process_message(%{"command" => "all_chatrooms"} = msg, tag, state) do
    data = msg["data"]
    IO.puts(data)
    Basic.ack(state.channel, tag)
    :ok = FrontEndChatserver.LogDatabase.store(msg)
  end

  defp process_message(%{"command" => "all_clients"} = msg, tag, state) do
    data = msg["data"]
    IO.puts(data)
    Basic.ack(state.channel, tag)
  end


  ########################################################################
  ##                                EXTRA                               ##
  ########################################################################

  defp process_message(msg, tag, state) do
    :ok = FrontEndChatserver.LogDatabase.store(msg)
    Basic.ack(state.channel, tag)
  end

  defp rabbitmq_setup(%@me{} = state) do
    # Create exchange, queue and bind them.
    :ok = AMQP.Exchange.declare(state.channel, @exchange, :fanout)
    {:ok, %{queue: name}} = AMQP.Queue.declare(state.channel, "", exclusive: true)
    :ok = AMQP.Queue.bind(state.channel, name, @exchange)

    # Limit unacknowledged messages to 1. THIS IS VERY SLOW! Just doing this for debugging
    :ok = Basic.qos(state.channel, prefetch_count: 1)

    # Register the GenServer process as a consumer. Consumer pid argument (3rd arg) defaults to self()
    {:ok, _unused_consumer_tag} = Basic.consume(state.channel, name)
  end
end
