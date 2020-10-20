# Game Orchestration Engine
class Move
  include Comparable

  def win_message(loser)
    @win_messages[loser.class]
  end

  def to_s
    @value
  end

  def <=>(other)
    return 1 if win_messages.key?(other.class)
    return -1 if other.win_messages.key?(self.class)
    0
  end

  protected

  attr_reader :win_messages
end

class Rock < Move
  def initialize
    @value = 'rock'
    @win_messages = {
      Lizard => 'Rock crushes lizard!',
      Scissors => 'Rock crushes scissors!'
    }
  end
end

class Paper < Move
  def initialize
    @value = 'paper'
    @win_messages = {
      Rock => 'Paper covers rock!',
      Spock => 'Paper disproves Spock!'
    }
  end
end

class Scissors < Move
  def initialize
    @value = 'scissors'
    @win_messages = {
      Paper => 'Scissors cuts paper!',
      Lizard => 'Scissors decapitates lizard!'
    }
  end
end

class Lizard < Move
  def initialize
    @value = 'lizard'
    @win_messages = {
      Spock => 'Lizard poisons Spock!',
      Paper => 'Lizard eats paper!'
    }
  end
end

class Spock < Move
  def initialize
    @value = 'spock'
    @win_messages = {
      Rock => 'Spock vaporizes rock!',
      Scissors => 'Spock smashes scissors!'
    }
  end
end

class Player
  attr_accessor :score
  attr_reader :move, :name

  def initialize
    set_name
    @score = 0
    @move_history = []
  end

  def move=(move)
    update_move_history(move)
    @move = move
  end

  def update_move_history(move)
    @move_history << move
  end

  def print_move_history
    puts "#{name}'s move history"
    @move_history.each_index do |index|
      puts "\tRound #{index + 1}: #{@move_history[index]}"
    end
  end
end

class Human < Player
  def set_name
    n = ''
    loop do
      puts "What's your name?"
      n = gets.chomp
      break unless n.empty?
      puts "Sorry, must enter a value."
    end
    @name = n
  end

  def choose(options)
    choice = nil
    move_strings = options.map(&:to_s)
    loop do
      options_str = options.join(', ')
      puts "Please choose #{options_str}:"
      choice = gets.chomp.downcase
      break if move_strings.include?(choice)
      puts "Sorry, invalid choice."
    end
    self.move = options[move_strings.find_index(choice)]
  end
end

class Computer < Player
  attr_reader :name

  def choose(options)
    self.move = choose_strategy(options)
  end

  def choose_strategy(options)
    options.sample
  end
end

class Hal < Computer
  def set_name
    @name = 'Hal'
  end
end

class R2d2 < Computer
  def set_name
    @name = 'R2D2'
  end
end

class Chappie < Computer
  def set_name
    @name = 'Chappie'
  end
end

class Sonny < Computer
  def set_name
    @name = 'Sonny'
  end
end

class Number5 < Computer
  def set_name
    @name = 'Number 5'
  end
end

class RPSGame
  attr_accessor :human, :computer, :last_winner

  MOVE_OPTIONS = [Rock.new, Paper.new, Scissors.new, Lizard.new, Spock.new]
  COMPUTER_OPTIONS = [Hal, R2d2, Chappie, Sonny, Number5]

  MAX_SCORE = 10
  SLEEP_TIME = 1.5

  def initialize
    @computer = COMPUTER_OPTIONS.sample.new
  end

  def display_welcome_message
    puts "Welcome to Rock, Paper, Scissors!"
    @human = Human.new
  end

  def display_goodbye_message
    puts "Thanks for playing Rock, Paper, Scissors! Good bye!"
  end

  def display_moves
    puts "#{human.name} chose #{human.move}."
    puts "#{computer.name} chose #{computer.move}."
  end

  def determine_winner
    if human.move > computer.move
      human.score += 1
      self.last_winner = human
    elsif human.move < computer.move
      computer.score += 1
      self.last_winner = computer
    else
      self.last_winner = :tie
    end
  end

  def display_winner
    determine_winner
    if last_winner == :tie
      puts "It's a tie!"
    else
      loser = last_winner == human ? computer : human
      puts last_winner.move.win_message(loser.move)
      puts "#{last_winner.name} won!"
    end
  end

  def display_score
    puts "First player to #{MAX_SCORE} wins!"
    puts "#{human.name}: #{human.score} points"
    puts "#{computer.name}: #{computer.score} points"
  end

  def play_again?
    answer = nil
    loop do
      puts "Would you like to play again or print the move history? (y/n/p)"
      answer = gets.chomp.downcase
      break if ['y', 'n'].include?(answer)
      [human, computer].each(&:print_move_history) if answer == 'p'
      puts "Sorry, must be y, n, or p." unless answer == 'p'
    end
    answer.downcase == 'y'
  end

  def players_choose
    human.choose(MOVE_OPTIONS)
    print "#{computer.name} is thinking"
    3.times do
      print "."
      sleep(SLEEP_TIME / 3)
    end
    computer.choose(MOVE_OPTIONS)
  end

  def game_over?
    last_winner != :tie && last_winner.score == MAX_SCORE
  end

  def clear_screen
    system('cls') || system('clear')
    display_score
  end

  def play
    display_welcome_message
    loop do
      clear_screen
      players_choose
      clear_screen
      display_moves
      display_winner
      break if game_over? || !play_again?
    end
    display_goodbye_message
  end
end

RPSGame.new.play
