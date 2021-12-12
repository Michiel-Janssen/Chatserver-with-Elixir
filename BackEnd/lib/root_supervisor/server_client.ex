defmodule RootSupervisor.ServerClient do
  use GenServer

  @me __MODULE__


  ########################################################################
  ##                                API                                 ##
  ########################################################################

  def start_link(init_arg) do
    case init_arg[:opts] do
      nil ->
        {:error, {:missing_arg, :opts}}

        opts ->
          GenServer.start_link(@me, init_arg, name: via_tuple(opts))
    end
  end

  def participate(client_server) do
    GenServer.call(via_tuple(client_server), {:participate, self()})
  end


  ########################################################################
  ##                              CALLBACKS                             ##
  ########################################################################

  @impl true
  def init(init_arg) do
    {:ok, init_arg}
  end

  @impl true
  def handle_call(:pop, _from, [head | tail]) do
    {:reply, head, tail}
  end


  ########################################################################
  ##                          HELPER FUNCTIONS                          ##
  ########################################################################

  defp via_tuple(arg) do
    {:via, Registry, {Registry.ChatRegistry, {:server_client, arg}}}
  end


end
