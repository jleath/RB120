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
    @value = calculate_value
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

  def calculate_value
    point_total = 0
    num_aces = 0
    @cards.each do |card|
      if card.ace?
        num_aces += 1
      elsif card.face_card?
        point_total += 10
      else
        point_total += card.value.to_i
      end
    end
    add_aces(num_aces, point_total)
  end

  def add_aces(num_aces, hand_value)
    num_aces.times do
      hand_value += hand_value + 11 > Game::BUST_VALUE ? 1 : 11
    end
    hand_value
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
    player_turn
    dealer_turn
    show_result
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
    IO.display("#{@status}")
    sleep(0.75)
  end

  def show_initial_cards
    display_hands
  end

  def take_turn(participant)
    display_hands
    while participant.hit?
      participant.take_card(@deck.draw_card)
      display_hands
    end
  end

  def player_turn
    @status = "Players turn..."
    take_turn(@player)
  end

  def dealer_turn
    @status = "Dealer's turn..."
    @show_dealer_hand = true
    take_turn(@dealer)
  end

  def show_result

  end
end

Game.new.start