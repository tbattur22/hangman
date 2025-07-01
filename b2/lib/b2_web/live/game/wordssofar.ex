defmodule B2Web.Live.Game.WordsSoFar do

  use B2Web, :live_component

  @states %{
    already_used: "You already picked that letter",
    bad_guess: "That's not in the word",
    good_guess: "Good guess!",
    initializing: "Type or click on your first guess",
    lost: "Sorry, you lost...",
    won: "You won!"
  }

  def mount(socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div class="grid place-items-center">
      <div class="words-so-far text-[150%]">
        <div>Turns left: <%= @tally.turns_left %></div>
        <%= state_name(@tally.game_state) %>
        <div>
          <%= maybe_reveal_word(@game, @tally) %>
        </div>
      </div>
      <div class="letters flex p-4">
        <%= for ch <- @tally.letters do %>
          <div class={"one-letter mr-4 text-[150%] #{if ch !== "_", do: "correct font-bold", else: ""}"}>
            <%= ch %>
          </div>
        <% end %>
      </div>
    </div>
    """
  end

  defp state_name(state) do
    @states[state] || "Unknown state"
  end

  defp maybe_reveal_word(game, %{game_state: :lost}) do
    word =
      Hangman.guessed_word(game)
      |>Enum.join(" ")
    "The word is: <" <> word <> ">"
  end
  defp maybe_reveal_word(_game, _tally), do: ""
end
