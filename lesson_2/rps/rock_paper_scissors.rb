# Game Orchestration Engine
class Move
  attr_reader :value

  VALUES = ['rock', 'paper', 'scissors', 'lizard', 'spock']
  WINNING_COMBOS = {
    'rock' => ['scissors', 'lizard'],
    'paper' => ['rock', 'spock'],
    'scissors' => ['paper', 'lizard'],
    'lizard' => ['spock', 'paper'],
    'spock' => ['scissors', 'rock']
  }
  WIN_MESSAGES = {
    'scissorspaper' => 'Scissors cuts paper!',
    'paperrock' => 'Paper covers rock!',
    'rocklizard' => 'Rock crushes lizard!',
    'lizardspock' => 'Lizard poisons Spock!',
    'spockscissors' => 'Spock smashes scissors',
    'scissorslizard' => 'Scissors decapitates lizard!',
    'lizardpaper' => 'Lizard eats paper!',
    'paperspock' => 'Paper disproves Spock!',
    'spockrock' => 'Spock vaporizes Rock!',
    'rockscissors' => 'Rock crushes scissors!'
  }

  def initialize(value)
    @value = value
  end

  def self.win_message(move1, move2)
    WIN_MESSAGES[move1.value + move2.value]
  end

  def >(other_move)
    WINNING_COMBOS[@value].include?(other_move.value)
  end

  def <(other_move)
    other_move > self
  end

  def to_s
    @value
  end
end

class Player
  attr_accessor :move, :name, :score

  def initialize
    set_name
    @score = 0
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
    self.name = n
  end

  def choose
    choice = nil
    loop do
      options_str = Move::VALUES.join(', ')
      puts "Please choose #{options_str}:"
      choice = gets.chomp
      break if Move::VALUES.include?(choice)
      puts "Sorry, invalid choice."
    end
    self.move = Move.new(choice)
  end
end

class Computer < Player
  def set_name
    self.name = ['R2D2', 'Hal', 'Chappie', 'Sonny', 'Number 5'].sample
  end

  def choose
    self.move = Move.new(Move::VALUES.sample)
  end
end

class RPSGame
  attr_accessor :human, :computer, :last_winner

  MAX_SCORE = 10
  SLEEP_TIME = 1.5

  def initialize
    @human = Human.new
    @computer = Computer.new
  end

  def display_welcome_message
    puts "Welcome to Rock, Paper, Scissors!"
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
      puts Move.win_message(last_winner.move, loser.move)
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
      puts "Would you like to play again? (y/n)"
      answer = gets.chomp
      break if ['y', 'n'].include?(answer.downcase)
      puts "Sorry, must be y or n."
    end
    answer.downcase == 'y'
  end

  def players_choose
    human.choose
    print "#{computer.name} is thinking"
    3.times do
      print "."
      sleep(SLEEP_TIME / 3)
    end
    computer.choose
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
