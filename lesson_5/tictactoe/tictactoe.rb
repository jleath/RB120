load 'fireworks.rb'
load 'ttt_input_output.rb'

class Board
  WINNING_LINES = [[1, 2, 3], [4, 5, 6], [7, 8, 9]] + # rows
                  [[1, 4, 7], [2, 5, 8], [3, 6, 9]] + # cols
                  [[1, 5, 9], [3, 5, 7]]              # diagonals
  ANIMATION_REPEATS = 4
  ANIMATION_REFRESH = 0.1 / 1.5
  SQUARE_ANIMATION = ['-', '\\', '|', '/']

  def initialize
    @squares = {}
    reset
  end

  # TODO: Get rid of this testing code
  def self.tie_board
    board = Board.new
    board.set_to_tie_state
    board
  end

  # TODO: Get rid of this testing code
  def set_to_tie_state
    @squares[1].marker = 'X'
    @squares[2].marker = 'O'
    @squares[3].marker = 'X'
    @squares[4].marker = 'O'
    @squares[5].marker = 'X'
    @squares[6].marker = 'O'
    @squares[7].marker = 'O'
    @squares[9].marker = 'O'
  end

  # rubocop:disable Metrics/AbcSize
  # rubocop:disable Metrics/MethodLength
  def draw
    puts "     |     |"
    puts "  #{@squares[1]}  |  #{@squares[2]}  |  #{@squares[3]}"
    puts "     |     |"
    puts "-----+-----+-----"
    puts "     |     |"
    puts "  #{@squares[4]}  |  #{@squares[5]}  |  #{@squares[6]}"
    puts "     |     |"
    puts "-----+-----+-----"
    puts "     |     |"
    puts "  #{@squares[7]}  |  #{@squares[8]}  |  #{@squares[9]}"
    puts "     |     |"
  end
  # rubocop:enable Metrics/AbcSize
  # rubocop:enable Metrics/MethodLength

  def []=(key, marker)
    @squares[key].marker = marker
  end

  def [](key)
    @squares[key]
  end

  def unmarked_keys
    @squares.keys.select { |key| @squares[key].unmarked? }
  end

  def full?
    unmarked_keys.empty?
  end

  def someone_won?
    !!winning_line
  end

  # returns winning line
  def winning_line
    WINNING_LINES.each do |line|
      squares = @squares.values_at(*line)
      if three_identical_squares?(squares)
        return squares
      end
    end
    nil
  end

  def animate_tie(human_score, computer_score)
    square_order = [1, 2, 3, 6, 9, 8, 7, 4, 5]
    @squares.values_at(*square_order).each do |square|
      animate_squares([square], human_score, computer_score, repeats: 1)
    end
  end

  def animate_win(human_score, computer_score)
    animate_squares(winning_line, human_score, computer_score)
  end

  def reset
    (1..9).each { |key| @squares[key] = Square.new }
  end

  private

  def three_identical_squares?(squares)
    markers = squares.select(&:marked?).collect(&:marker)
    return false if markers.size != 3
    markers.min == markers.max
  end

  def animate_squares(squares, score1, score2, repeats: ANIMATION_REPEATS)
    frames = SQUARE_ANIMATION.size
    (frames * repeats).times do |frame|
      sleep(ANIMATION_REFRESH)
      squares.each { |square| square.marker = SQUARE_ANIMATION[frame % frames] }
      TTTInputOutput.clear_screen
      Scoreboard.display(score1, score2)
      draw
    end
    squares.each { |square| square.marker = Square::INITIAL_MARKER }
  end
end

class Square
  INITIAL_MARKER = ' '
  attr_accessor :marker

  def initialize(marker=INITIAL_MARKER)
    @marker = marker
  end

  def to_s
    @marker
  end

  def marked?
    !unmarked?
  end

  def unmarked?
    marker == INITIAL_MARKER
  end
end

class Player
  attr_reader :marker, :name
  attr_accessor :score

  def initialize(marker, name)
    @marker = marker
    @score = 0
    @name = name
  end
end

class Human < Player
  def choose_square(board)
    TTTInputOutput.choose_from_options(board.unmarked_keys)
  end
end

class Computer < Player
end

class Scoreboard
  def self.display(player_score, computer_score)
    winner_indicator = get_winner_indicator(player_score, computer_score)
    puts(' TIC   TAC   TOE')
    puts('------------------')
    puts('player    computer')
    puts("  #{player_score}    #{winner_indicator}    #{computer_score}")
  end

  RIGHT_INDICATOR = '-|>'
  LEFT_INDICATOR = '<|-'
  TIE_INDICATOR = '-|-'

  def self.get_winner_indicator(left_score, right_score)
    if left_score < right_score
      RIGHT_INDICATOR
    elsif left_score > right_score
      LEFT_INDICATOR
    else
      TIE_INDICATOR
    end
  end
end

class TTTGame
  HUMAN_MARKER = 'X'
  COMPUTER_MARKER = 'O'
  FIRST_TO_MOVE = HUMAN_MARKER
  SCORE_LIMIT = 2
  FORCE_TIE = true

  attr_reader :board, :human, :computer

  def initialize
    @board = FORCE_TIE ? Board.tie_board : Board.new
    @human = Human.new(HUMAN_MARKER, 'Player')
    @computer = Player.new(COMPUTER_MARKER, 'Computer')
    @curr_marker = FIRST_TO_MOVE
  end

  def play
    TTTInputOutput.clear_screen
    display_welcome_message
    main_game
    display_goodbye_message
  end

  private

  def display_welcome_message
    TTTInputOutput.display("Welcome to TicTacToe!")
    TTTInputOutput.display("The first player to win #{SCORE_LIMIT}" \
                           " rounds is the champion.")
    TTTInputOutput.display("Press Enter when you are ready to begin!",
                           newline: false)
    gets
  end

  def display_board
    Scoreboard.display(human.score, computer.score)
    board.draw
    puts ""
  end

  def clear_screen_and_display_board
    TTTInputOutput.clear_screen
    display_board
  end

  def human_moves
    TTTInputOutput.display("#{human.name}'s turn")
    square = human.choose_square(board)
    board[square] = human.marker
  end

  def display_thinking_sequence
    TTTInputOutput.display("The computer is thinking", newline: false)
    3.times do
      print('.')
      sleep(0.35)
    end
  end

  def computer_moves
    display_thinking_sequence
    square = board.unmarked_keys.sample
    board[square] = computer.marker
  end

  def update_scores
    winning_line = board.winning_line
    return if winning_line.nil?

    case board.winning_line.first.marker
    when human.marker then human.score += 1
    when computer.marker then computer.score += 1
    end
  end

  def display_tie
    board.animate_tie(human.score, computer.score)
    TTTInputOutput.clear_screen
    Scoreboard.display(human.score, computer.score)
    TTTInputOutput.display("It's a tie!")
  end

  def display_win(winning_line)
    winning_marker = winning_line.first.marker
    board.animate_win(human.score, computer.score)
    TTTInputOutput.clear_screen
    win_msg = winning_marker == human.marker ? "You won!" : "The computer won!"
    Scoreboard.display(human.score, computer.score)
    TTTInputOutput.display(win_msg)
  end

  def display_result
    winning_line = board.winning_line
    if winning_line.nil?
      display_tie
    else
      display_win(winning_line)
    end
  end

  def at_score_limit?(player)
    player.score == SCORE_LIMIT
  end

  def display_champion
    if at_score_limit?(human)
      TTTInputOutput.clear_screen
      FireworksAnimation.display("  Congratulations!!\nYou are the champion!")
    else
      TTTInputOutput.display("You lose! The computer is the champion!")
    end
  end

  def display_goodbye_message
    TTTInputOutput.display("Thanks for playing Tic Tac Toe! Goodbye!")
  end

  def reset_board
    board.reset
    @curr_marker = FIRST_TO_MOVE
    TTTInputOutput.clear_screen
  end

  def human_turn?
    @curr_marker == HUMAN_MARKER
  end

  def switch_player
    @curr_marker = human_turn? ? COMPUTER_MARKER : HUMAN_MARKER
  end

  def current_player_moves
    if human_turn?
      human_moves
    else
      computer_moves
    end
    switch_player
  end

  def player_move
    loop do
      current_player_moves
      break if board.someone_won? || board.full?
      clear_screen_and_display_board
    end
  end

  def game_over?
    at_score_limit?(human) || at_score_limit?(computer)
  end

  def play_again?
    TTTInputOutput.get_yes_no("Would you like to continue?")
  end

  def main_game
    TTTInputOutput.clear_screen
    loop do
      play_round
      break if game_over?
      break unless play_again?
      reset_board
    end
    display_champion
  end
end

def play_round
  display_board
  player_move
  update_scores
  display_result
end

game = TTTGame.new
game.play
