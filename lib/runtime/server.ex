defmodule Hangman.Runtime.Server do
  alias Hangman.Impl.Game
  @type t :: pid()
  use GenServer

  @registry :hangman_server_registry

  # client process

  def start_link(uid) do
    name = "HangmanServer_" <> Integer.to_string(uid)
    GenServer.start_link(__MODULE__, nil, name: {:via, Registry, {@registry, name}})
  end

  # server process

  def init(_) do
    {:ok, Game.new_game() }
  end

  def handle_call({ :make_move, guess}, _from, game) do
    { updated_game, updated_tally } = Game.make_move(game, guess)
    {:reply, updated_tally, updated_game}
  end

  def handle_call({ :tally }, _from, game) do
    {:reply, Game.tally(game), game}
  end

  def handle_call({ :guessed_word }, _from, game) do
    {:reply, game.letters, game}
  end

  def handle_call({ :play_again }, _from, _game) do
    new_game = Game.new_game()
    tally = Game.tally(new_game)
    {:reply, tally, new_game}
  end
end
