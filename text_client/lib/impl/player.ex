defmodule TextClient.Impl.Player do
  @typep game :: Hangman.game
  @typep tally :: Hangman.tally
  @typep state :: { game, tally }

  @spec start(game) :: :ok
  def start(game) do
    # game = Hangman.new_game()
    tally = Hangman.tally(game)
    interact({ game, tally })
  end

  # @type state :: :initializing | :won | :lost | :good_guess | :bad_guess | :already_used

  @spec interact(state) :: :ok

  def interact({_game, _tally = %{ game_state: :won }}) do
    IO.puts "Congratulations. You won!"
  end
  def interact({game, _tally = %{ game_state: :lost }}) do
    IO.puts "Sorry, You lost ... the word was #{game.letters}"
  end

  def interact({ game, tally }) do
    IO.puts feedback_for(tally)
    IO.puts current_word(tally)

    tally = Hangman.make_move(game, get_guess())
    interact({ game, tally })
  end

  ###############
  def feedback_for(tally = %{ game_state: :initializing}) do
    "Welcome! I'm thinking of a #{tally.letters |> length} letter word"
  end
  def feedback_for(_tally = %{ game_state: :good_guess}), do: "Good guess!"
  def feedback_for(_tally = %{ game_state: :bad_guess}), do: "Sorry, that letter is not in the word"
  def feedback_for(_tally = %{ game_state: :already_used}), do: "You already used that letter"
  ################

  def current_word(tally) do
    [
      "Words so far: ",
      tally.letters |> Enum.join(" "),
      "  turns left: ",
      tally.turns_left |> to_string,
      "  used so far: ",
      tally.used |> Enum.join(",")
    ]
  end

  def get_guess() do
    IO.gets("Next letter: ")
    |> String.trim()
    |> String.downcase()
  end
end
