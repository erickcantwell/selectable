# frozen_string_literal: true

# Test Modules
module Tester
  class StringTestClass
    def self.selectable_for
      ["strings"]
    end
  end

  class FloatTestClass
    def self.selectable_for
      [Float]
    end
  end

  class NotSelectable
  end

  module IntegerTestModule
    def self.selectable_for
      [Integer, 3]
    end
  end
end

module MisconfiguredTester
  module NotArray
    def self.selectable_for
      "notanarray"
    end
  end
end

RSpec.describe Selectable do
  it "has a version number" do
    expect(Selectable::VERSION).not_to be nil
  end

  describe "#selectable" do
    it "raises an exception if the selectable class or module is misconfigured" do
      s = described_class.new(namespace: MisconfiguredTester)
      expect do
        s.selectable
      end.to raise_error(StandardError, "selectable_for must be an array in MisconfiguredTester::NotArray")
    end

    it "returns a hash of selectable objects" do
      s = described_class.new(namespace: Tester)
      expect(s.selectable).to include({ Tester::StringTestClass => ["strings"],
                                        Tester::FloatTestClass => [Float],
                                        Tester::IntegerTestModule => [Integer, 3] })
    end
  end

  describe "#selectors" do
    it "returns a flattened list of all selectors" do
      s = described_class.new(namespace: Tester)
      expect(s.selectors).to contain_exactly("strings", Float, Integer, 3)
    end
  end

  describe "#selectable?" do
    it "returns true for a selector that exists" do
      s = described_class.new(namespace: Tester)
      expect(s.selectable?("strings")).to be true
    end

    it "returns false for a selector that does not exist" do
      s = described_class.new(namespace: Tester)
      expect(s.selectable?("randothing")).to be false
    end
  end

  describe "#for" do
    it "raises an exception if the input is unselectable" do
      s = described_class.new(namespace: Tester)
      expect do
        s.for("badinput")
      end.to raise_error(UnSelectable, "badinput is unselectable")
    end

    it "returns the selected class for 'strings' input" do
      s = described_class.new(namespace: Tester)
      expect(s.for("strings").new).to be_a(Tester::StringTestClass)
    end

    it "returns the selected module for 'Integer' input" do
      s = described_class.new(namespace: Tester)
      expect(s.for(Integer)).to eq(Tester::IntegerTestModule)
    end

    it "returns the selected module for 'Float' input" do
      s = described_class.new(namespace: Tester)
      expect(s.for(Float).new).to be_a(Tester::FloatTestClass)
    end
  end
end
