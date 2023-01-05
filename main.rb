module Rules
  @@COLORS = {
    R: 'Red',
    B: 'Blue',
    Y: 'Yellow',
    G: 'Green',
    P: 'Purple',
    W: 'White',
  }
  @@CODE_LENGTH = 4

  @@MAX_GUESSES = 10

  def self.COLORS
    @@COLORS
  end

  def self.CODE_LENGTH
    @@CODE_LENGTH
  end

  def self.MAX_GUESSES
    @@MAX_GUESSES
  end
end

class Code
  def make_code(input)
    return false unless valid_code?(input)

    @code = input.chars
    true
  end

  def valid_code?(input)
    input.length == Rules.CODE_LENGTH and input.chars.all? { |char| Rules.COLORS.key?(char.to_sym) }
  end
end

class Guesser < Code
  attr_reader :code
  attr_accessor :guess_count

  def initialize
    @guess_count = 0
  end

end

class Selector < Code
  attr_reader :code
  def generate_code
    @code = Array.new(Rules.CODE_LENGTH) { Rules.COLORS.keys.sample.to_s }
  end
end

class Board
  attr_reader :board

  def initialize
    @board = []
  end

  def newline(code, guess)
    result = "#{guess.join} | "
    result += code.map.with_index do |pin, i|
      if pin == guess[i]
        'B'
      elsif guess.any? { |answer| answer == pin}
        'W'
      else
        ''
      end
    end.sort.join
    @board.push(result)
  end

  def render
    @board.each_with_index { |line, i| puts "Guess #{i + 1}: #{line}" }
  end
end

class Game
  def initialize
    @player_score = 0
    @computer_score = 0
  end

  def game_over?
    @guesser.code == @selector.code
  end

  def help_message
    puts "Pins: #{Rules.COLORS.keys}"
    puts 'Results: B - A Pin is the right color and in the right spot. W - Pin is right color but wrong spot.'
  end

  def init_state
    @selector = Selector.new
    @guesser = Guesser.new
    @board = Board.new
  end
  def game_start
    loop do
      init_state()
      puts 'MASTERMIND'
      puts '----------'
      puts 'Play as the guesser or selector (s for selector)'
      player = gets.downcase.chomp
      unless player == 's'
        guesser_loop()
      else
        selector_loop
      end
      puts "\nPlay again? (n to quit)"
      again = gets.downcase.chomp
      return if again == 'n'
    end
  end

  def guesser_loop
    @selector.generate_code
    while @guesser.guess_count <= Rules.MAX_GUESSES do 
      @guesser.guess_count += 1
      loop do
        puts "\nGuess a #{Rules.CODE_LENGTH} length code (type 'help' for options)"
        input = gets.upcase.chomp
        if input == 'HELP'
          help_message
        elsif @guesser.valid_code?(input)
          @guesser.make_code(input)
          break
        else
          puts "Invalid input."
        end
      end
      if game_over?()
        puts "You win in #{@guesser.guess_count} guesses."
        break
      end
      puts "The code did not match."
      @board.newline(@selector.code, @guesser.code)
      @board.render
    end
    puts 'You could not guess the code in time' if @guesser.guess_count >= Rules.MAX_GUESSES
    @computer_score += 1 + @guess.guess_count
  end

  def selector_loop
    puts "not implemented"
  end 
end

game = Game.new
game.game_start