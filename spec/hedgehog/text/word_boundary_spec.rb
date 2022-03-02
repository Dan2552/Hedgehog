describe Hedgehog::WordBoundary do
  def find_word_boundary(*args)
    Hedgehog::WordBoundary.find_word_boundary(*args)
  end

  def find_line_boundary(*args)
    Hedgehog::WordBoundary.find_line_boundary(*args)
  end

  it "finds a word boundary" do
    expect(find_word_boundary("hello world", 0, true)).to eq(5)
    expect(find_word_boundary("hello world", 1, true)).to eq(5)
    expect(find_word_boundary("hello world", 2, true)).to eq(5)
    expect(find_word_boundary("hello world", 4, true)).to eq(5)
    expect(find_word_boundary("hello world", 5, true)).to eq(11)
    expect(find_word_boundary("hello world", 6, true)).to eq(11)
    expect(find_word_boundary("hello world", 7, true)).to eq(11)
    expect(find_word_boundary("hello world", 8, true)).to eq(11)
    expect(find_word_boundary("hello world", 9, true)).to eq(11)
    expect(find_word_boundary("hello world", 10, true)).to eq(11)
    expect(find_word_boundary("hello world", 11, true)).to eq(11)

    expect(find_word_boundary("hello world", 0, false)).to eq(0)
    expect(find_word_boundary("hello world", 1, false)).to eq(0)
    expect(find_word_boundary("hello world", 2, false)).to eq(0)
    expect(find_word_boundary("hello world", 4, false)).to eq(0)
    expect(find_word_boundary("hello world", 5, false)).to eq(0)
    expect(find_word_boundary("hello world", 6, false)).to eq(0)
    expect(find_word_boundary("hello world", 7, false)).to eq(6)
    expect(find_word_boundary("hello world", 8, false)).to eq(6)
    expect(find_word_boundary("hello world", 9, false)).to eq(6)
    expect(find_word_boundary("hello world", 10, false)).to eq(6)
    expect(find_word_boundary("hello world", 11, false)).to eq(6)

    expect(find_word_boundary("fn find_word_boundary(text: &str,", 0, true)).to eq(2)
    expect(find_word_boundary("fn find_word_boundary(text: &str,", 2, true)).to eq(21)
    expect(find_word_boundary("fn find_word_boundary(text: &str,", 21, true)).to eq(26)
    expect(find_word_boundary("fn find_word_boundary(text: &str,", 26, true)).to eq(27)
    expect(find_word_boundary("fn find_word_boundary(text: &str,", 27, true)).to eq(32)
    expect(find_word_boundary("fn find_word_boundary(text: &str,", 32, true)).to eq(33)

    expect(find_word_boundary("hello world hello world", 12, true)).to eq(17)
  end

  it "finds a line boundary" do
    single_line = "a b c";

    expect(find_line_boundary(single_line, 0, true)).to eq(5)
    expect(find_line_boundary(single_line, 1, true)).to eq(5)
    expect(find_line_boundary(single_line, 2, true)).to eq(5)
    expect(find_line_boundary(single_line, 3, true)).to eq(5)
    expect(find_line_boundary(single_line, 4, true)).to eq(5)
    expect(find_line_boundary(single_line, 5, true)).to eq(5)

    expect(find_line_boundary(single_line, 0, false)).to eq(0)
    expect(find_line_boundary(single_line, 1, false)).to eq(0)
    expect(find_line_boundary(single_line, 2, false)).to eq(0)
    expect(find_line_boundary(single_line, 3, false)).to eq(0)
    expect(find_line_boundary(single_line, 4, false)).to eq(0)
    expect(find_line_boundary(single_line, 5, false)).to eq(0)

    multiline = "a b\nc d\ne f"

    expect(find_line_boundary(multiline, 0, true)).to eq(3)
    expect(find_line_boundary(multiline, 1, true)).to eq(3)
    expect(find_line_boundary(multiline, 2, true)).to eq(3)
    expect(find_line_boundary(multiline, 3, true)).to eq(3)
    expect(find_line_boundary(multiline, 4, true)).to eq(7)
    expect(find_line_boundary(multiline, 5, true)).to eq(7)
    expect(find_line_boundary(multiline, 6, true)).to eq(7)
    expect(find_line_boundary(multiline, 7, true)).to eq(7)
    expect(find_line_boundary(multiline, 8, true)).to eq(11)
    expect(find_line_boundary(multiline, 9, true)).to eq(11)
    expect(find_line_boundary(multiline, 10, true)).to eq(11)
    expect(find_line_boundary(multiline, 11, true)).to eq(11)

    expect(find_line_boundary(multiline, 0, false)).to eq(0)
    expect(find_line_boundary(multiline, 1, false)).to eq(0)
    expect(find_line_boundary(multiline, 2, false)).to eq(0)
    expect(find_line_boundary(multiline, 3, false)).to eq(0)
    expect(find_line_boundary(multiline, 4, false)).to eq(4)
    expect(find_line_boundary(multiline, 5, false)).to eq(4)
    expect(find_line_boundary(multiline, 6, false)).to eq(4)
    expect(find_line_boundary(multiline, 7, false)).to eq(4)
    expect(find_line_boundary(multiline, 8, false)).to eq(8)
    expect(find_line_boundary(multiline, 9, false)).to eq(8)
    expect(find_line_boundary(multiline, 10, false)).to eq(8)
    expect(find_line_boundary(multiline, 11, false)).to eq(8)
  end
end
