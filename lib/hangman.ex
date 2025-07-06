defmodule Hangman do

  alias Hangman.Runtime.Server
  alias Hangman.Type

  @opaque game :: Server.t
  @opaque tally :: Type.tally

  @registry :hangman_server_registry

  @spec new_game(Integer.t) :: game
  def new_game(uid) do
    case Registry.lookup(@registry, "HangmanServer_" <> Integer.to_string(uid)) do
      [] ->
        {:ok, pid} = Hangman.Runtime.Application.start_game(uid)
        pid

      [{pid2, _}] ->
        pid2
    end
  end

  @spec make_move(game, String.t) :: tally
  def make_move(game, guess) do
    GenServer.call(game, {:make_move, guess})
  end

  @spec tally(game) :: tally
  def tally(game) do
    GenServer.call(game, {:tally})
  end

  @spec guessed_word(game) :: game
  def guessed_word(game) do
    GenServer.call(game, {:guessed_word})
  end

  @spec play_again(game) :: game
  def play_again(game) do
    GenServer.call(game, {:play_again})
  end
end
