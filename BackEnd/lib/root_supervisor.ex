defmodule RootSupervisor do
  @default_client_server :general_client


  def dump_all_registered_processes() do
    Registry.select(Registry.ChatRegistry, [
      {{:"$1", :"$2", :"$3"}, [], [{{:"$1", :"$2", :"$3"}}]}
    ])
  end

  def run_setup() do
    {:ok, _} = RootSupervisor.DynamicSupervisorClient.add_client_instance(@default_client_server)

    Registry.register(
      Registry.ChatRegistry,
      {@default_client_server, :participant, "iex_shell"},
      :ignore_value
    )

    RootSupervisor.ServerClient.participate(@default_client_server)
  end

end
