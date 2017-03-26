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
  

  # Only works with latin and greek charsets.
  # An input phrase can only be one of five things:
  # 1)      Already only in greek or only in latin charset.
  # 2)      Written in a mixed charset, but can be written with just the greek charset.
  # 3)      Written in a mixed charset, but can be written with just the latin charset.
  # 4)      Written in a mixed charset, but cannot be written with only one of the [greek, latin] charsets.
  #           In this case we split the phrase into words and apply the above rules to each word seperately.
  #           If case 4 applies to a single word, there is nothing more we can do for it than return it "as is".
  # 5)      Written in a mixed charset, but can be written either with just the greek charset or just the latin charset.
  #
  # Note:   We are deliberately ignoring case 5, as it is of no use at the moment as a separate case. 
  # It is actually the initersection of cases 2 and 3. Using case 2 instead.
  # @params input [String] the string we want to de-bi-linguify (!)
  # @return       [String] the de-bi-linguized string
  def dbl(input)
    if(is_greek_only?(input) || is_latin_only?(input)) # Case 1
      input
    elsif(can_write_only_greek?(input))                # Case 2
      return_in_greek(input)
    elsif(can_write_only_latin?(input))                # Case 3
      return_in_latin(input)
    else                                               # Case 4
      return_in_mixed_charset(input)
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
  def return_in_mixed_charset(input)
    # Split the phrase in words and recursively try to return each word in the "correct" charset
    # If that is not possible (e.g. a word contains both "Φ" and "C", return it as it was originally
    # We first split the input phrase, based on the SYMBOLS delimiters 
    words_arr = input.split(/(?<=[#{SYMBOLS}])/)
    if words_arr.length == 1            # If it was only one word, return it.
      return (words_arr.join.to_s)
    else                                # Else apply dbl to each word we got after splitting input
      words_arr2 =[]
      words_arr.each do |word|
        words_arr2 << dbl(word)
      end
      return words_arr2.join.to_s
    end
  end

end

