defmodule HangmanRuntimeGameTest do
  use ExUnit.Case
  alias Hangman
  alias Hangman.Runtime.Server
  @registry :hangman_server_registry

  setup do
    {:ok, _pid} = Registry.start_link(keys: :unique, name: @registry)
    :ok
  end

  test "new game server always returns the same pid for the same user id" do
    userId = 123
    case Server.start_link(userId) do
      {:ok, pid} ->
        tally = GenServer.call(pid, {:tally})
        assert tally.turns_left == 7
        assert tally.game_state == :initializing
        assert length(tally.letters) > 0

        # confirm server process is registered under correct name
        [{pid2, _}] = Registry.lookup(@registry, "HangmanServer_123")
        assert pid == pid2

        # confirm starting new game returns the same pid for the same user id
        assert pid == Hangman.new_game(userId)
        # confirm starting new game returns different pid for different user
        assert pid != Hangman.new_game(222)

      {:error, reason} ->
        assert true == false, "Failed to start linked Game Server. Reason #{inspect(reason)}"
    end
  end
end
