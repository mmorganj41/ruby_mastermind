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
    @result = []
  end

  def newline(guess)
    result = "#{guess.join} | "
    @result.each { |key, val| result += key.to_s*val}
    @board.push(result)
  end

  def render
    @board.each_with_index { |line, i| puts "Guess #{i + 1}: #{line}" }
  end

  def result(code, guess)
    pins = code.each_with_index.reduce({ B: 0, W: 0, C: [] }) do |result, (pin, i)|
      if pin == guess[i]
        result[:B] += 1
        result[:C].push(:B)
      else
        result[:C].push(pin)
      end
      result
    end
    guess.each_with_index do |pin, i|
      next if pins[:C][i] == :B

      match = pins[:C].index(pin)
      if match
        pins[:W] += 1 
        pins[:C][match] = :W
      end
    end
    pins.delete(:C)
    @result = pins
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
      puts "\nScore is Player: #{@player_score} to Computer: #{@computer_score}"
      puts "\nPlay again? (n to quit)"
      again = gets.downcase.chomp
      return if again == 'n'
    end
  end

  def guesser_loop
    @selector.generate_code
    while @guesser.guess_count <= Rules.MAX_GUESSES do 
      @guesser.guess_count += 1
      puts @selector.code
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
      @board.result(@selector.code, @guesser.code)
      @board.newline(@guesser.code)
      @board.render
    end
    puts 'You could not guess the code in time' if @guesser.guess_count >= Rules.MAX_GUESSES
    @computer_score += 1 + @guesser.guess_count
  end

  def selector_loop
    puts "not implemented"
  end 
end

game = Game.new
game.game_start