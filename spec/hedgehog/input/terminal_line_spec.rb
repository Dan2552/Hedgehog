describe Hedgehog::Input::TerminalLine do
  let(:cols) { 80 }
  let(:rows) { 40 }
  let(:text) { "Hello World" }
  let(:cursor_index) { 1 }
  let(:prefix) { nil }

  let(:described_instance) do
    described_class.new(
      cols: cols,
      rows: rows,
      text: text,
      cursor_index: cursor_index,
      prefix: prefix
    )
  end

  describe "#cursor_index" do
    subject { described_instance.cursor_index }

    it "returns the cursor_index" do
      expect(subject).to eq(cursor_index)
    end
  end

  describe "#cols" do
    subject { described_instance.cols }

    it "returns the cols" do
      expect(subject).to eq(cols)
    end
  end

  describe "#rows" do
    subject { described_instance.rows }

    it "returns the rows" do
      expect(subject).to eq(rows)
    end
  end

  describe "#cursor_cols" do
    subject { described_instance.cursor_cols }

    it "returns the cursor_cols" do
      expect(subject).to eq(cursor_index)
    end

    context "when there is a prefix" do
      let(:prefix) { "something > " }

      it "considers the prefix" do
        expect(subject).to eq(prefix.length + cursor_index)
      end
    end

    context "when cursor is on the 2nd row" do
      let(:text) { "saaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaae" }
      let(:cursor_index) { 80 }

      it "returns only the amount of columns for that line" do
        expect(subject).to eq(0)
      end
    end

    context "when there are lines before the cursor" do
      let(:text) { ("a" * 80) + "b\ncc" }
      let(:cursor_index) { 84 }

      it "counts them as rows" do
        expect(subject).to eq(2)
      end
    end
  end

  describe "#cursor_rows" do
    subject { described_instance.cursor_rows }

    it "returns the cursor_rows" do
      expect(subject).to eq(0)
    end

    context "when cursor is on the 2nd row" do
      let(:text) { "saaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaae" }
      let(:cursor_index) { 80 }

      it "returns that row" do
        expect(subject).to eq(1)
      end
    end

    context "when there is a prefix" do
      let(:prefix) { "a" * 80 }

      it "considers the prefix" do
        expect(subject).to eq(1)
      end
    end

    context "when there are lines before the cursor" do
      let(:text) { ("a" * 80) + "b\ncc" }
      let(:cursor_index) { 84 }

      it "counts them as rows" do
        expect(subject).to eq(2)
      end
    end
  end

  describe "#max_cursor_cols" do
    subject { described_instance.max_cursor_cols }

    it "returns the max_cursor_cols" do
      expect(subject).to eq(text.length)
    end

    context "when there is a prefix" do
      let(:prefix) { "something > " }

      it "considers the prefix" do
        expect(subject).to eq(prefix.length + text.length)
      end
    end

    context "when there are multiple rows" do
      let(:text) { ("a" * 80) + "b\ncc" }
      let(:cursor_index) { 84 }

      it "only considers the last line" do
        expect(subject).to eq(2)
      end
    end
  end

  describe "#max_cursor_rows" do
    subject { described_instance.max_cursor_rows }

    it "returns the max_cursor_rows" do
      expect(subject).to eq(0)
    end

    context "when there is a prefix" do
      let(:prefix) { "a" * 80 }

      it "considers the prefix" do
        expect(subject).to eq(1)
      end
    end

    context "when there are multiple rows" do
      let(:text) { ("a" * 80) + "b\ncc\n" }
      let(:cursor_index) { 84 }

      it "returns the last row" do
        expect(subject).to eq(3)
      end
    end
  end

  describe "#cursor_index=" do
    let(:new_value) { 5 }
    subject { described_instance.cursor_index = new_value }

    it "returns the new value" do
      expect(subject).to eq(new_value)
    end

    it "changes the result of #cursor_index" do
      expect { subject }
        .to change { described_instance.cursor_index }
        .from(cursor_index)
        .to(new_value)
    end
  end

  describe "#text" do
    subject { described_instance.text }

    it "returns the text" do
      expect(subject).to eq(text)
    end
  end

  describe "#text=" do
    let(:new_text) { "new text" }
    subject { described_instance.text = new_text }

    it "returns the new text" do
      expect(subject).to eq(new_text)
    end

    it "changes the value of #text" do
      expect { subject }
        .to change { described_instance.text }
        .from(text)
        .to(new_text)
    end

    it "sets #cursor_index to visible length of the text" do
      expect { subject }
        .to change { described_instance.cursor_index }
        .from(cursor_index)
        .to(8)
    end

    it "sets #cursor_rows to the end of the text" do
      subject
      expect(described_instance.cursor_rows).to eq(0)
    end

    it "sets #cursor_cols to the end of the text" do
      subject
      expect(described_instance.cursor_cols).to eq(8)
    end
  end

  describe "#terminal_did_resize" do
    let(:new_cols) { 40 }
    let(:new_rows) { 20 }
    subject { described_instance.terminal_did_resize(new_cols, new_rows) }

    it "changes cols" do
      expect { subject }
        .to change { described_instance.cols }
        .from(cols)
        .to(new_cols)
    end

    it "changes rows" do
      expect { subject }
        .to change { described_instance.rows }
        .from(rows)
        .to(new_rows)
    end

    context "when the cursor's position would have wrapped" do
      let(:text) { "a" * 100 }
      let(:cursor_index) { 41 }

      it "changes cursor_rows to adjust for the wrapping" do
        expect { subject }
          .to change { described_instance.cursor_rows }
          .from(0)
          .to(1)
      end

      it "changes cursor_cols to adjust for the wrapping" do
        expect { subject }
          .to change { described_instance.cursor_cols }
          .from(cursor_index)
          .to(1)
      end
    end

    context "when the cursor's position would not have wrapped" do
      let(:cursor_index) { 39 }

      it "does not change cursor_rows" do
        expect { subject }
          .to_not change { described_instance.cursor_rows }
      end

      it "does not change cursor_cols" do
        expect { subject }
          .to_not change { described_instance.cursor_cols }
      end
    end
  end

  describe "#insert" do
    let(:index) { 1 }
    let(:value) { "hello" }
    subject { described_instance.insert(index, value) }

    it "returns the manipulated text" do
      expect(subject).to eq("Hhelloello World")
    end

    it "changes the output of #text" do
      expect { subject }
        .to change { described_instance.text }
        .from("Hello World")
        .to("Hhelloello World")
    end

    it "changes the output of #dirty_indexes" do
      expect { subject }
        .to change { described_instance.dirty_indexes }
        .from([])
        .to([1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15])
    end
  end

  describe "#[]" do
    let(:index_or_range) { 1 }
    subject { described_instance[index_or_range] }

    it "returns the value at the index" do
      expect(subject).to eq("e")
    end
  end

  describe "#[]=" do
    let(:index_or_range) { 1 }
    let(:value) { "hello" }
    subject { described_instance[index_or_range] = value }

    it "returns value" do
      expect(subject).to eq(value)
    end

    it "changes the output of #text" do
      expect { subject }
        .to change { described_instance.text }
        .from("Hello World")
        .to("Hhellollo World")
    end

    it "changes the output of #dirty_indexes" do
      expect { subject }
        .to change { described_instance.dirty_indexes }
        .from([])
        .to([1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14])
    end

    context "when only replacing a character" do
      let(:value) { "o" }

      it "changes the output of #text" do
        expect { subject }
          .to change { described_instance.text }
          .from("Hello World")
          .to("Hollo World")
      end

      it "only sets the single character on #dirty_indexes" do
        expect { subject }
          .to change { described_instance.dirty_indexes }
          .from([])
          .to([1])
      end
    end

    context "when a range" do
      let(:index_or_range) { 0..4 }
      let(:value) { "Goodbye" }

      it "changes the output of #text" do
        expect { subject }
          .to change { described_instance.text }
          .from("Hello World")
          .to("Goodbye World")
      end

      it "changes the output of #dirty_indexes" do
        expect { subject }
          .to change { described_instance.dirty_indexes }
          .from([])
          .to([0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12])
      end
    end
  end

  describe "#dirty_indexes" do
    subject { described_instance.dirty_indexes }

    it "returns an array" do
      expect(subject).to eq([])
    end
  end

  describe "#visible_length" do
    subject { described_instance.visible_length }

    it "returns the length of the text" do
      expect(subject).to eq(text.length)
    end

    context "when including color characters" do
      let(:visible_text) { "Hello World" }
      let(:text) do
        Hedgehog::StringExtensions.with_color(
          visible_text,
          color: 128,
          bg_color: 125
        )
      end

      it "returns the length without counting the color characters" do
        expect(subject).to eq(visible_text.length)
      end
    end
  end
end
