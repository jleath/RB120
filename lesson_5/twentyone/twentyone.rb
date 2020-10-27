load 'input_output.rb'

class Card
  POSSIBLE_SUITS = ['diamonds', 'clubs', 'spades', 'hearts']
  POSSIBLE_VALUES = ['A', '2', '3', '4', '5', '6',
                     '7', '8', '9', '10', 'J', 'Q', 'K']
  attr_reader :suit, :value

  def initialize(suit, value)
    @suit = suit
    @value = value
  end

  def ace?
    value == 'A'
  end

  def face_card?
    ['J', 'Q', 'K'].include?(value)
  end

  def to_s
    value
  end
end

class Deck
  def initialize
    @cards = build
  end

  # Will return nil if the deck is empty
  def draw_card
    @cards.pop
  end

  private

  def build
    result = []
    Card::POSSIBLE_SUITS.each do |suit|
      Card::POSSIBLE_VALUES.each do |value|
        result << Card.new(suit, value)
      end
    end
    result.shuffle
  end
end

class Hand
  attr_reader :value

  def initialize
    @cards = []
    @value = 0
  end

  def add_card(card)
    @cards << card
    calculate_value
  end

  def blackjack?
    value == Game::BUST_VALUE
  end

  def busted?
    value > Game::BUST_VALUE
  end

  def to_s
    @cards.join(' ')
  end

  def num_cards
    @cards.size
  end

  def up_card
    @cards.first
  end

  private

  def aces_count
    @cards.select(&:ace?).size
  end

  def calculate_value
    @value = 0
    num_aces = @cards.select(&:ace?).size
    @cards.each do |card|
      if card.face_card?
        @value += 10
      elsif !card.ace?
        @value += card.value.to_i
      end
    end
    add_aces(num_aces)
  end

  def add_aces(num_aces)
    num_aces.times do
      @value += @value + 11 > Game::BUST_VALUE ? 1 : 11
    end
  end
end

class Player
  attr_reader :hand

  def initialize
    @hand = Hand.new
  end

  def take_card(card)
    @hand.add_card(card)
  end

  def hit?
    if hand.blackjack? || hand.busted?
      false
    else
      move = IO.choose_from_options(Game::VALID_MOVE_OPTIONS)
      move == 'hit'
    end
  end
end

class Dealer < Player
  def hit?
    hand.value < Game::MAX_DEALER_HIT
  end
end

class Game
  BUST_VALUE = 21
  MAX_DEALER_HIT = 17
  INITIAL_HAND_SIZE = 2
  VALID_MOVE_OPTIONS = %w(hit stay)

  def initialize
    @player = Player.new
    @dealer = Dealer.new
    @deck = Deck.new
    @status = ""
    @show_dealer_hand = false
  end

  def start
    IO.clear_screen
    deal_cards
    show_initial_cards
    take_turns
    display_hands
    show_result
  end

  def take_turns
    return if game_over?
    player_turn
    return if game_over?
    dealer_turn
  end

  def game_over?
    if @player.hand.busted? || @player.hand.blackjack? ||
       @dealer.hand.blackjack?
      @show_dealer_hand = true
      true
    else
      false
    end
  end

  def deal_cards
    @status = "Dealing Cards..."
    INITIAL_HAND_SIZE.times do
      @player.take_card(@deck.draw_card)
      display_hands
      @dealer.take_card(@deck.draw_card)
      display_hands
    end
    @status = ""
  end

  def display_hands
    IO.clear_screen
    dealer_hand = @show_dealer_hand ? @dealer.hand : @dealer.hand.up_card
    dealer_points = @show_dealer_hand ? " -> #{@dealer.hand.value}" : ""
    IO.display("Dealer Hand: #{dealer_hand}#{dealer_points}")
    IO.display("Player Hand: #{@player.hand} -> #{@player.hand.value}")
    IO.display(@status.to_s)
    sleep(0.75)
  end

  def show_initial_cards
    display_hands
  end

  def take_turn(participant)
    display_hands
    while participant.hit? && !participant.hand.blackjack?
      participant.take_card(@deck.draw_card)
      display_hands
    end
    display_hands
  end

  def player_turn
    @status = "Players turn..."
    take_turn(@player)
    @status = ""
    display_hands
  end

  def dealer_turn
    @status = "Dealer's turn..."
    @show_dealer_hand = true
    take_turn(@dealer)
    @status = ""
    display_hands
  end

  def win_string
    if @dealer.hand.blackjack?
      "Dealer Blackjack! You lose!"
    elsif @dealer.hand.busted?
      "Dealer busted! You win!!"
    elsif @player.hand.blackjack?
      "Blackjack! You win!!"
    elsif @player.hand.busted?
      "You busted! You lose!"
    end
  end

  def show_result
    special_state = win_string
    if !special_state.nil?
      IO.display(special_state)
    elsif @player.hand.value > @dealer.hand.value
      IO.display("You win!!")
    elsif @player.hand.value < @dealer.hand.value
      IO.display("You lose!")
    else
      IO.display("It's a draw!")
    end
  end
end

Game.new.start
