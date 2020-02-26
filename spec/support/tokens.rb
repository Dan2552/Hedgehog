def t(*token_types)
  token_types.map do |type|
    type_map = {
      word_starting_with_letter: "abc",
      space: " ",
      number: "123",
      word_starting_with_number: "1bc",
      equals: "=",
      single_quote: "'",
      double_quote: "\"",
      backtick: "`",
      pipe: "|",
      dollar: "$",
      left_parenthesis: "(",
      right_parenthesis: ")",
      newline: "\n",
      backslash: "\\",
      or: "||",
      and: "&&",
      semicolon: ";",
      forward_slash: "/",
      end: ""
    }
    text = type_map[type]
    raise "Unknown token for testing: #{type}" unless text
    Hedgehog::Parse::Token.new(type, text)
  end
end
