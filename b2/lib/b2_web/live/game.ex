defmodule B2Web.Live.Game do

  use B2Web, :live_view

  def mount(_params, _sessions, socket) do
    game = Hangman.new_game()
    tally = Hangman.tally(game)
    socket = socket|> assign(%{game: game, tally: tally})

    {:ok, socket}
  end

  def handle_event("make_move", %{ "key" => key }, socket) do
    tally = Hangman.make_move(socket.assigns.game, key)
    { :noreply, assign(socket, :tally, tally) }
  end

  def render (assigns) do
    ~H"""
    <div class="game-holder h-fit grid place-items-center md:flex" phx-window-keyup="make_move">
      <div class="mb-1">
        <.live_component module={__MODULE__.Figure} id="1" tally={assigns.tally} />
      </div>
      <div>
        <.live_component module={__MODULE__.Alphabet} id="2" tally={assigns.tally} />
        <.live_component module={__MODULE__.WordsSoFar} id="3" tally={assigns.tally} game={assigns.game} />
      </div>
    </div>
    """
  end
end
