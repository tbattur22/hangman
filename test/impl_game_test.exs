defmodule HangmanImplGameTest do
  use ExUnit.Case
  alias Hangman.Impl.Game

  test "new game returns structure" do
    game = Game.new_game
    assert game.turns_left == 7
    assert game.game_state == :initializing
    assert length(game.letters) > 0
  end

  test "new game returns correct workd" do
    game = Game.new_game("wombat")
    assert game.turns_left == 7
    assert game.game_state == :initializing
    assert game.letters == ["w", "o", "m", "b", "a", "t"]
  end

  test "state doesn't change if a game is won or lost" do
    for state <- [:won, :lost] do
      game = Game.new_game("wombat")
      game = Map.put(game, :game_state, state)
      { new_game, _tally } = Game.make_move(game, "x")
      assert new_game == game
    end
  end

  test "a duplicate letter us reported" do
    game = Game.new_game()
    {game, _tally} = Game.make_move(game, "x")
    assert game.game_state !== :already_used
    {game, _tally} = Game.make_move(game, "y")
    assert game.game_state !== :already_used
    {game, _tally} = Game.make_move(game, "x")
    assert game.game_state == :already_used
  end

  test "we record letters used" do
    game = Game.new_game()
    {game, _tally} = Game.make_move(game, "x")
    {game, _tally} = Game.make_move(game, "y")
    {game, _tally} = Game.make_move(game, "x")
    assert MapSet.equal?(game.used, MapSet.new(["x", "y"]))
  end

  test "we recognize a letter in word" do
    game = Game.new_game("wombat")
    {game, _tally} = Game.make_move(game, "m")
    assert game.game_state == :good_guess
    {game, _tally} = Game.make_move(game, "t")
    assert game.game_state == :good_guess
  end

  test "we recognize a letter not in word" do
    game = Game.new_game("wombat")
    {game, _tally} = Game.make_move(game, "x")
    assert game.game_state == :bad_guess
    {game, _tally} = Game.make_move(game, "t")
    assert game.game_state == :good_guess
    {game, _tally} = Game.make_move(game, "z")
    assert game.game_state == :bad_guess
  end

  test "a sequence of move for the word hello" do
    [
      [ "a", :bad_guess,    6,    [ "_", "_", "_", "_", "_"], [ "a" ] ],
      [ "a", :already_used, 6,    [ "_", "_", "_", "_", "_"], [ "a" ] ],
      [ "e", :good_guess,   6,    [ "_", "e", "_", "_", "_"], [ "a", "e" ] ],
      [ "x", :bad_guess,    5,    [ "_", "e", "_", "_", "_"], [ "a", "e", "x" ] ]
    ]
    |> test_sequence_of_moves("hello")
  end

  test "a sequence of move leading to win for the word mommy" do
    [
      [ "a", :bad_guess,    6,    [ "_", "_", "_", "_", "_"], [ "a" ] ],
      [ "e", :bad_guess,    5,    [ "_", "_", "_", "_", "_"], [ "a", "e" ] ],
      [ "x", :bad_guess,    4,    [ "_", "_", "_", "_", "_"], [ "a", "e", "x" ] ],
      [ "o", :good_guess,   4,    [ "_", "o", "_", "_", "_"], [ "a", "e", "o", "x" ] ],
      [ "t", :bad_guess,    3,    [ "_", "o", "_", "_", "_"], [ "a", "e", "o", "t", "x" ] ],
      [ "m", :good_guess,   3,    [ "m", "o", "m", "m", "_"], [ "a", "e", "m", "o", "t", "x" ] ],
      [ "y", :won,          3,    [ "m", "o", "m", "m", "y"], [ "a", "e", "m", "o", "t", "x", "y" ] ]
    ]
    |> test_sequence_of_moves("mommy")
  end

    test "a sequence of move leading to win again for the word bracket" do
    [
      [ "a", :good_guess,   7,    [ "_", "_", "a", "_", "_", "_", "_"], [ "a" ] ],
      [ "c", :good_guess,   7,    [ "_", "_", "a", "c", "_", "_", "_"], [ "a", "c" ] ],
      [ "o", :bad_guess,    6,    [ "_", "_", "a", "c", "_", "_", "_"], [ "a", "c", "o" ] ],
      [ "e", :good_guess,   6,    [ "_", "_", "a", "c", "_", "e", "_"], [ "a", "c", "e", "o" ] ],
      [ "b", :good_guess,   6,    [ "b", "_", "a", "c", "_", "e", "_"], [ "a", "b", "c", "e", "o" ] ],
      [ "r", :good_guess,   6,    [ "b", "r", "a", "c", "_", "e", "_"], [ "a", "b", "c", "e", "o", "r" ] ],
      [ "t", :good_guess,   6,    [ "b", "r", "a", "c", "_", "e", "t"], [ "a", "b", "c", "e", "o", "r", "t" ] ],
      [ "k", :won,   6,    [ "b", "r", "a", "c", "k", "e", "t"], [ "a", "b", "c", "e", "k", "o", "r", "t" ] ],
    ]
    |> test_sequence_of_moves("bracket")
  end

  test "a sequence of move leading to loss for the word apple" do
    [
      [ "y", :bad_guess,   6,    [ "_", "_", "_", "_", "_"], [ "y" ] ],
      [ "o", :bad_guess,   5,    [ "_", "_", "_", "_", "_"], [ "o", "y" ] ],
      [ "s", :bad_guess,   4,    [ "_", "_", "_", "_", "_"], [ "o", "s", "y" ] ],
      [ "i", :bad_guess,   3,    [ "_", "_", "_", "_", "_"], [ "i", "o", "s", "y" ] ],
      [ "k", :bad_guess,   2,    [ "_", "_", "_", "_", "_"], [ "i", "k", "o", "s", "y"] ],
      [ "t", :bad_guess,   1,    [ "_", "_", "_", "_", "_"], [ "i", "k", "o", "s", "t", "y"] ],
      [ "q", :lost,        0,    [ "_", "_", "_", "_", "_"], [ "i", "k", "o", "q", "s", "t", "y" ] ],
    ]
    |> test_sequence_of_moves("apple")
  end


  def test_sequence_of_moves(listOfMoves, word) do
    game = Game.new_game(word)
    Enum.reduce(listOfMoves, game, &check_one_move/2)
  end

  defp check_one_move([guess, state, turns, letters, used], game) do
    { game, tally } = Game.make_move(game, guess)

    assert tally.game_state == state
    assert tally.turns_left == turns
    assert tally.letters == letters
    assert tally.used == used

    game
  end

end
