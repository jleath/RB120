require 'pry'
class Firework
  SPRITES = ['.', '.', '.', '.', '.', '*', '%', '*', '%', '.']
  ANIMATION_HEIGHTS = [4, 3, 2, 1, 0, 0, 0, 0, 0, 0]
  MIN_HEIGHT = 3
  MAX_HEIGHT = 5
  MAX_DELAY = 30
  NUM_FRAMES = SPRITES.size
  attr_reader :delay, :height, :x_position

  def initialize(img_width)
    @x_position = rand(img_width)
    @delay = rand(MAX_DELAY)
    @height = rand(MIN_HEIGHT..MAX_HEIGHT)
  end

  def active?(frame)
    sprite_frame = frame - @delay
    (0...SPRITES.size).include?(sprite_frame)
  end

  def animation_sprite(frame)
    sprite_frame = frame - @delay
    SPRITES[sprite_frame]
  end

  def animation_height(frame)
    sprite_frame = frame - @delay
    ANIMATION_HEIGHTS[sprite_frame]
  end
end

class FireworksAnimation
  NUM_FIREWORKS = 15
  FIREWORKS_COLUMNS = 23
  ANIMATION_REFRESH = 0.1

  def initialize
    @fireworks = generate_fireworks
    @total_num_frames = Firework::MAX_DELAY + Firework::NUM_FRAMES
  end

  def display
    (0...@total_num_frames).each do |curr_frame|
      sprite_map = update_animation(curr_frame)
      puts sprite_map
      puts '  Congratulations!!'
      puts 'You are the champion!'
      sleep(ANIMATION_REFRESH)
      system('clear') || system('cls')
    end
  end

  private

  def generate_fireworks
    result = []
    NUM_FIREWORKS.times { result << Firework.new(FIREWORKS_COLUMNS) }
    result
  end

  def update_animation(curr_frame)
    result = []
    Firework::MAX_HEIGHT.times { result << ' ' * FIREWORKS_COLUMNS }
    @fireworks.each do |firework|
      x_pos = firework.x_position
      y_pos = firework.animation_height(curr_frame)
      if firework.active?(curr_frame)
        result[y_pos][x_pos] = firework.animation_sprite(curr_frame)
      end
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
  SCORE_LIMIT = 1

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
