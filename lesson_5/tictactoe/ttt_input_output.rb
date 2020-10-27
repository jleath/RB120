module TTTInputOutput
  PROMPT = "> "

  def self.display(msg, newline: true)
    output = "#{PROMPT} #{msg}"
    if newline
      puts output
    else
      print output
    end
  end

  def self.joinor(arr, delim = ', ', join_word = 'or')
    arr = arr[0..-1]
    if arr.size <= 2
      arr.join(" #{join_word} ")
    else
      arr[-1] = "#{join_word} #{arr[-1]}"
      arr.join(delim)
    end
  end

  def self.choose_from_options(options)
    choice = nil
    loop do
      display("Choose from (#{joinor(options)})")
      choice = gets.chomp.to_i
      break if options.include?(choice)

      display("Sorry, that is not a valid choice. Please try again.")
    end
    choice
  end

  def self.get_yes_no(msg)
    answer = nil
    loop do
      display("#{msg} (y/n)")
      answer = gets.chomp.downcase
      break if %(y n).include?(answer)
      display("Sorry, must be y or n. Please try again.")
    end
    answer == 'y'
  end

  def self.clear_screen
    system('clear') || system('cls')
  end
end
