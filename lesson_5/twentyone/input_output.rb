class IO
  PROMPT = "> "
  def self.clear_screen
    system('clear') || system('cls')
  end

  def self.display(msg, newline: true)
    output_str = "#{PROMPT}#{msg}"
    newline ? puts(output_str) : print(output_str)
  end

  def self.choose_from_options(options)
    options_str = self.joinor(options)
    answer = nil
    loop do
      puts "Would you like to #{options_str}? (Type #{options_str}) "
      answer = gets.chomp.downcase
      break if %w(hit stay).include?(answer)
      puts "Sorry, that is not a valid option. Please try again."
    end
    answer
  end

  private

  def self.joinor(arr, delim = ', ', join_word = 'or')
    arr = arr[0..-1]
    if arr.size <= 2
      arr.join(" #{join_word} ")
    else
      arr[-1] = "#{join_word} #{arr[-1]}"
      arr.join(delim)
    end
  end
end