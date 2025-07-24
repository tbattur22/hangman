defmodule Hangman.Runtime.Application do

  @super_name GameStarter
  use Application
  @registry :hangman_server_registry

  def start(_type, _args) do

    supervisor_spec = [
      { DynamicSupervisor, strategy: :one_for_one, name: @super_name },
      {Registry, [keys: :unique, name: @registry]},
    ]

    Supervisor.start_link(supervisor_spec, strategy: :one_for_one)
  end

  def start_game(uid) do
    case Registry.lookup(@registry, "HangmanServer_#{uid}") do
      [{pid, _}] -> {:ok, pid}
      [] -> DynamicSupervisor.start_child(@super_name, { Hangman.Runtime.Server, uid})
    end
  end
end
