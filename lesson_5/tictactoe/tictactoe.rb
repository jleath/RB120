class Firework
  attr_reader :delay, :height

  def initialize(delay, height)
    @delay = delay
    @height = height
  end
end

class FireworksAnimation
  FIREWORKS = [[' ', ' ', ' ', ' ', '.', '*', '%', '*', '%', '.'],
               [' ', ' ', ' ', '.', ' ', ' ', ' ', ' ', ' ', ' '],
               [' ', ' ', '.', ' ', ' ', ' ', ' ', ' ', ' ', ' '],
               [' ', '.', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' '],
               ['.', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ']].freeze

  NUM_FIREWORKS = 15
  MAX_FIREWORKS_DELAY = 30
  FIREWORKS_COLUMNS = 23
  MIN_FIREWORK_HEIGHT = 3
  MAX_FIREWORK_HEIGHT = 5
  ANIMATION_FRAMES = FIREWORKS[0].size
  ANIMATION_LINES = FIREWORKS.size
  ANIMATION_REFRESH = 0.1

  def initialize
    generate_fireworks
    @animation_rows = [' ' * FIREWORKS_COLUMNS] * MAX_FIREWORK_HEIGHT
    @total_num_frames = MAX_FIREWORKS_DELAY + ANIMATION_FRAMES
  end

  def display
    (0...@total_num_frames).each do |curr_frame|
      update_animation!(curr_frame)
      puts @animation_rows
      puts '  Congratulations!!'
      puts 'You are the champion!'
      sleep(ANIMATION_REFRESH)
      system('clear') || system('cls')
    end
  end

  private

  def generate_fireworks
    # seeding the fireworks sequence to make sure that the random
    # number generation doesn't make us wait to long to see frames
    @fireworks_info = {}
    NUM_FIREWORKS.times do
      column_no = rand(FIREWORKS_COLUMNS)
      delay = rand(MAX_FIREWORKS_DELAY)
      height = rand(MIN_FIREWORK_HEIGHT..MAX_FIREWORK_HEIGHT)
      @fireworks_info[column_no] = Firework.new(delay, height)
    end
  end

  def update_animation!(curr_frame)
    @animation_rows.each_index do |line_no|
      @animation_rows[line_no] =
        update_animation_row(line_no, curr_frame)
    end
  end

  def update_animation_row(line_no, curr_frame)
    result = ' ' * FIREWORKS_COLUMNS
    @fireworks_info.each do |column, firework|
      frame = curr_frame - firework.delay
      line = line_no - (MAX_FIREWORK_HEIGHT - firework.height)
      next unless frame.between?(0, ANIMATION_FRAMES - 1)
      next unless line.between?(0, ANIMATION_LINES - 1)
      result[column] = FIREWORKS[line][frame]
    end
    result
  end
end

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

  def initialize
    @board = Board.new
    @human = Player.new(HUMAN_MARKER)
    @computer = Player.new(COMPUTER_MARKER)
    @curr_marker = FIRST_TO_MOVE
  end

  def play
    clear_screen
    display_welcome_message
    main_game
    display_goodbye_message
  end

  private

  def display(msg, newline: true)
    if newline
      puts "> #{msg}"
    else
      print "> #{msg}"
    end
  end

  def display_welcome_message
    display("Welcome to TicTacToe!")
    display("The first player to win #{SCORE_LIMIT} rounds is the champion.")
    display("Press Enter when you are ready to begin!", newline: false)
    gets
  end

  def clear_screen
    system('clear') || system('cls')
  end

  def get_winner_indicator(left_score, right_score)
    if left_score < right_score
      '-|>'
    elsif left_score > right_score
      '<|-'
    else
      '-|-'
    end
  end

  def display_scoreboard
    winner_indicator = get_winner_indicator(human.score, computer.score)
    puts(' TIC   TAC   TOE')
    puts('------------------')
    puts('player    computer')
    puts("  #{human.score}    #{winner_indicator}    #{computer.score}")
  end

  def display_board
    display_scoreboard
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
    square = nil
    loop do
      display("Choose a square (#{joinor(board.unmarked_keys)})")
      square = gets.chomp.to_i
      break if board.unmarked_keys.include?(square)

      display("Sorry, that is not a valid choice. Please try again.")
    end
    board[square] = human.marker
  end

  def computer_moves
    square = board.unmarked_keys.sample
    board[square] = computer.marker
  end

  def update_scores
    case board.winning_marker
    when human.marker then human.score += 1
    when computer.marker then computer.score += 1
    end
  end

  def display_result
    clear_screen_and_display_board
    case board.winning_marker
    when human.marker then display("You won!")
    when computer.marker then display("Computer won!")
    else display("It's a tie!")
    end
  end

  def at_score_limit?(player)
    player.score == SCORE_LIMIT
  end

  def display_champion
    if at_score_limit?(human)
      clear_screen
      FireworksAnimation.new.display
    else
      display("You lose! The computer is the champion!")
    end
  end

  def display_goodbye_message
    display("Thanks for playing Tic Tac Toe! Goodbye!")
  end

  def reset_board
    board.reset
    @curr_marker = FIRST_TO_MOVE
    clear_screen
  end

  def display_play_again_message
    display("Let's play again!")
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
      display("Player's turn")
      human_moves
    else
      display("Computer's turn")
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
    at_score_limit?(human) || at_score_limit?(computer)
  end

  def play_again?
    answer = nil
    loop do
      display("Would you like to continue? (y/n): ", newline: false)
      answer = gets.chomp.downcase
      break if %w(y n).include?(answer)
      display("Sorry, must be y or n.")
    end
    answer == 'y'
  end

  def main_game
    clear_screen
    loop do
      play_round
      break if game_over?
      break unless play_again?
      reset_board
      display_play_again_message
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
