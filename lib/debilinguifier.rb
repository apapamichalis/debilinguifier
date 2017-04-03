# This only works with capital AND detoned characters of latin and greek charsets

module DeBiLinguifier
  extend self

  # The symbols
  SYMBOLS = '\s\.\,\@\d\-\(\)\:\/\&\''.freeze
  # A regular expression to check if the input phrase's characters all belong in the greek charset
  GREEK_LOOKING_CHARS = Regexp.new("(^[Α-ΩABEHIKMNOPTXYZ#{SYMBOLS}]+)+$").freeze
  # A regular expression to check if the input phrase's characters all belong in the latin charset
  LATIN_LOOKING_CHARS = Regexp.new("(^[A-ZΑΒΕΗΙΚΜΝΟΡΤΥΧΖ#{SYMBOLS}]+)+$").freeze
  # A regular expression to match strings already written only with latin charset
  LATIN_ALPHABET_PLUS_SYMBOLS = Regexp.new("(^[A-Z#{SYMBOLS}]+)+$").freeze
  # A regular expression to match strings already written only with latin charset
  GREEK_ALPHABET_PLUS_SYMBOLS = Regexp.new("(^[Α-Ω#{SYMBOLS}]+)+$").freeze
  

  ## 
  # Only works with latin and greek charsets.
  # An input phrase can only be one of five things:
  # 1)      Already only in greek or only in latin charset.
  # 2)      Written in a mixed charset, but can be written with just the greek charset.
  # 3)      Written in a mixed charset, but can be written with just the latin charset.
  # 4)      Written in a mixed charset, but cannot be written with only one of the [greek, latin] charsets.
  #           In this case we split the phrase into words and apply the above rules to each word seperately.
  #           If case 4 applies to a single word, then we have to return it greek-ified or latin-ified.
  #           This way we will be able to produce SQL queries in a more deterministic way.
  #           (Actually, when searching for a phrase that has been processed by our dbl before writting to the db,
  #            we will also have to process through dbl the phrase we are looking for before quering the db).
  #            
  # 5)      Written in a mixed charset, but can be written either with just the greek charset or just the latin charset 
  #         (greek bias is the default and only behavior in this case)
  #
  # Note:   We are deliberately ignoring case 5, as it is of no use at the moment as a separate case. 
  # It is actually the initersection of cases 2 and 3. Using case 2 instead.
  # @params input [String] the string we want to de-bi-linguify (!)
  # @return       [String] the de-bi-linguized string
  def dbl(input, bias='greek')
    if(is_greek_only?(input) || is_latin_only?(input)) # Case 1
      input
    elsif(can_write_only_greek?(input))                # Case 2
      return_in_greek(input)
    elsif(can_write_only_latin?(input))                # Case 3
      return_in_latin(input)
    else                                               # Case 4
      return_in_mixed_charset(input, bias)
    end
  end

  # Determine if the input phrase is already only in greek charset
  def is_greek_only?(input)
    !!(input.match(GREEK_ALPHABET_PLUS_SYMBOLS))
  end

  # Determine if the input phrase is already only in latin charset
  def is_latin_only?(input)
    !!(input.match(LATIN_ALPHABET_PLUS_SYMBOLS))
  end

  # Determine if the whole phrase can be written only with greek charset
  def can_write_only_greek?(input)
    !!(input.match(GREEK_LOOKING_CHARS))
  end

  # Determine if the whole phrase can be written only with latin charset
  def can_write_only_latin?(input)
    !!(input.match(LATIN_LOOKING_CHARS))
  end

  # Return the phrase using the greek characters only
  def return_in_greek(input)
    input.tr('abehikmnoptxyz'.upcase, 'αβεηικμνορτχυζ'.upcase)
  end

  # Return the phrase using the latin characters only
  def return_in_latin(input)
    input.tr('αβεηικμνορτχυζ'.upcase, 'abehikmnoptxyz'.upcase) 
  end

  # Return the phrase using both charsets
  def return_in_mixed_charset(input, bias)
    # Split the phrase in words and recursively try to return each word in the "correct" charset
    # If that is not possible (e.g. a word contains both "Φ" and "C", the word must either be greek-ified (default) 
    # or latin-ified. The reason for this is that we will be able to do SQL queries, as long as the word - or phrase
    # we are looking for has been passed through dbl.
    # We first split the input phrase, based on the SYMBOLS delimiters 
    words_arr = input.split(/(?<=[#{SYMBOLS}])/)
    if words_arr.length == 1            # If it was only one word, return it, according to the bias.
      if bias == 'greek'
        return return_in_greek(words_arr.join.to_s)  # If the bias is 'greek', return the word 'greek-ified'
      elsif bias == 'latin'
        return return_in_latin(words_arr.join.to_s)  # Else if bias is 'latin' return it 'latinified'.
      else 
        return (words_arr.join.to_s)                 # Else return it as-is (not advisable!)
      end
    else                                # Else apply dbl to each word we got after splitting input
      words_arr2 =[]
      words_arr.each do |word|
        words_arr2 << dbl(word)
      end
      return words_arr2.join.to_s
    end
  end

end

