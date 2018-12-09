def stub_characters(*char_names)
  chars = char_names
    .map { |char_name| char_backwards_map(char_name) }
    .map { |char| Hedgehog::Input::Characters::Character.new(char) }

  characters = double
  allow(Hedgehog::Input::Characters)
    .to receive(:new)
    .and_return(characters)

  expect(characters)
    .to receive(:get_next)
    .and_return(*chars)
end

def char_backwards_map(char_name)
  Hedgehog::Input::Mapping::KNOWN_KEYS.each do |k, v|
    return k if v == char_name
  end
  char_name.to_s
end
