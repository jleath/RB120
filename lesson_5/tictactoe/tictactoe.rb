class Board
  WINNING_LINES = [[1, 2, 3], [4, 5, 6], [7, 8, 9]] + # rows
                  [[1, 4, 7], [2, 5, 8], [3, 6, 9]] + # cols
                  [[1, 5, 9], [3, 5, 7]]              # diagonals

  def initialize
    @squares = {}
    reset
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

  def unmarked_keys
    @squares.keys.select { |key| @squares[key].unmarked? }
  end

  def full?
    unmarked_keys.empty?
  end

  def someone_won?
    !!winning_marker
  end

  # returns winning marker or nil
  def winning_marker
    WINNING_LINES.each do |line|
      squares = @squares.values_at(*line)
      if three_identical_squares?(squares)
        return squares.first.marker
      end
    end
    nil
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
  attr_reader :marker
  attr_accessor :score

  def initialize(marker)
    @marker = marker
    @score = 0
  end
end

class TTTGame
  HUMAN_MARKER = 'X'
  COMPUTER_MARKER = 'O'
  FIRST_TO_MOVE = HUMAN_MARKER
  SCORE_LIMIT = 2

  attr_reader :board, :human, :computer
  attr_accessor :last_winner

  def initialize
    @board = Board.new
    @human = Player.new(HUMAN_MARKER)
    @computer = Player.new(COMPUTER_MARKER)
    @curr_marker = FIRST_TO_MOVE
    @last_winner = nil
  end

  def play
    clear_screen
    display_welcome_message
    main_game
    display_goodbye_message
  end

  private

  def display_welcome_message
    puts "Welcome to Tic Tac Toe!"
    puts ""
  end

  def clear_screen
    system('clear') || system('cls')
  end

  def display_board
    puts "You're a #{human.marker}. Computer is a #{computer.marker}."
    puts ""
    board.draw
    puts ""
  end

  def clear_screen_and_display_board
    clear_screen
    display_board
  end

  def joinor(arr, delim = ', ', join_word = 'or')
    arr = arr[0..-1]
    if arr.size <= 2
      arr.join(" #{join_word} ")
    else
      arr[-1] = "#{join_word} #{arr[-1]}"
      arr.join(delim)
    end
  end

  def human_moves
    puts "Choose a square (#{joinor(board.unmarked_keys)}): "
    square = nil
    loop do
      square = gets.chomp.to_i
      break if board.unmarked_keys.include?(square)

      puts "Sorry, that's not a valid choice."
    end
    board[square] = human.marker
  end

  def computer_moves
    square = board.unmarked_keys.sample
    board[square] = computer.marker
  end

  def determine_winner
    self.last_winner = case board.winning_marker
                       when HUMAN_MARKER then human
                       when COMPUTER_MARKER then computer
                       else :tie
                       end
    last_winner.score += 1
  end

  def display_result
    clear_screen_and_display_board
    determine_winner
    if last_winner == human
      puts "You won!"
    elsif last_winner == computer
      puts "Computer won!"
    else
      puts "It's a tie!"
    end
  end

  def display_champion
    if last_winner == human
      puts "You are the champion!"
    else
      puts "The computer is the champion!"
    end
  end

  def display_goodbye_message
    puts "Thanks for playing Tic Tac Toe! Goodbye!"
  end

  def reset
    board.reset
    @curr_marker = FIRST_TO_MOVE
    clear_screen
  end

  def display_play_again_message
    puts "Let's play again!"
    puts ""
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
      clear_screen_and_display_board if human_turn?
    end
  end

  def game_over?
    return true if last_winner != :tie && last_winner.score == SCORE_LIMIT
    if user_forfeit?
      self.last_winner = computer
      true
    else
      false
    end
  end

  def user_forfeit?
    answer = nil
    message = last_winner == human ? "" : " after that humiliating defeat"
    loop do
      puts "Would you like to continue#{message}? (y/n)"
      answer = gets.chomp.downcase
      break if %w(y n).include?(answer)
      puts "Sorry, must be y or n."
    end
    answer == 'n'
  end

  # display welcome message
  # start the game
  # display the scoreboard
  # display the board
  # each player takes their turn until the round is completed
  # if either player has the winning number of points, 
  #  end the game and display champion
  # otherwise
  #   if the player lost the round, ask if they would like to forfeit
  #   if the player won the round, ask if they would like to continue
  #   if the player chooses to continue, start the next round
  #   otherwise
  #     the computer is automatically the champion and the game ends
  # TODO: implement some kind of scoreboard
  def main_game
    loop do
      play_round
      break if game_over?
      reset
      display_play_again_message
    end
    display_champion
  end
end

def play_round
  display_board
  player_move
  display_result
end

game = TTTGame.new
game.play
