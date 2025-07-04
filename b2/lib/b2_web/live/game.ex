defmodule B2Web.Live.Game do

  use B2Web, :live_view

  def mount(_params, _sessions, socket) do
    if (connected?(socket)) do
      game = Hangman.new_game()
      tally = Hangman.tally(game)

      {:ok, socket|> assign(%{game: game, tally: tally})}
    else
      {:ok, socket}
    end
  end

  def handle_event("make_move", %{ "key" => key }, socket) do
    tally = Hangman.make_move(socket.assigns.game, key)
    { :noreply, assign(socket, :tally, tally) }
  end

  def render (%{game: _game, tally: _tally} = assigns) do
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

  @doc """
  No need to return any html for 1st static html render
  """
  def render (assigns) do
    ~H"""
    """
  end
end
