defmodule RootSupervisor.DynamicSupervisorClient do
  use DynamicSupervisor

  @me __MODULE__


  ########################################################################
  ##                              START                                 ##
  ########################################################################

  def start_link(init_arg) do
    DynamicSupervisor.start_link(@me, init_arg, name: @me)
  end

  @impl true
  def init(_init_arg) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end


  ########################################################################
  ##                            FUNCTIONS                               ##
  ########################################################################

  def add_client_instance(opts) do
    DynamicSupervisor.start_child(@me, {RootSupervisor.ServerClient, opts: opts})
  end
end
