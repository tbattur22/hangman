defmodule Hangman.Runtime.Server do
  require Logger
  alias Hangman.Impl.Game
  alias Hangman.Runtime.Watchdog
  @type t :: pid()

  @idle_timeout 1 * 60 * 60 * 1000   # 1 hour

  use GenServer

  @registry :hangman_server_registry

  # client process

  def start_link(uid) do
    name = "HangmanServer_" <> Integer.to_string(uid)
    GenServer.start_link(__MODULE__, nil, name: {:via, Registry, {@registry, name}})
  end

  def child_spec(uid) do
    %{
      id: {:hangman_server, uid},
      start: {__MODULE__, :start_link, [uid]},
      restart: :transient,  # only restart on abnormal exit
      shutdown: 5000,
      type: :worker
    }
  end


  # server process

  @impl true
  def init(_) do
    Process.flag(:trap_exit, true)
    watcher = Watchdog.start(@idle_timeout)
    {:ok, {Game.new_game(), watcher}}
  end

  @impl true
  def handle_call({ :make_move, guess}, _from, {game, watcher}) do
    Watchdog.im_alive(watcher)
    { updated_game, updated_tally } = Game.make_move(game, guess)
    {:reply, updated_tally, {updated_game, watcher}}
  end

  @impl true
  def handle_call({ :tally }, _from, {game, watcher}) do
    Watchdog.im_alive(watcher)
    {:reply, Game.tally(game), { game, watcher }}
  end

  @impl true
  def handle_call({ :guessed_word }, _from, {game, watcher}) do
    Watchdog.im_alive(watcher)
    {:reply, game.letters, {game, watcher}}
  end

  @impl true
  def handle_call({ :play_again }, _from, {_game, watcher}) do
    Watchdog.im_alive(watcher)
    new_game = Game.new_game()
    tally = Game.tally(new_game)
    {:reply, tally, { new_game, watcher}}
  end

  @impl true
  def handle_info({:watchdog_expired, _watchdog_pid}, _state) do
    IO.puts("Game session expired due to inactivity.")
    {:stop, :normal, :expired}
  end
end
