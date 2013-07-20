require 'rspec'
require_relative "../lib/ExponentSet"
describe ExponentSet do
  it "should contain element hash when initialized" do
    es = ExponentSet.new({:a => 1, :b => 2, :c => 3})
    es.should == ExponentSet[*%i{a b b c c c}]
  end

  describe "when #add(object)" do
    let(:set) { ExponentSet.new.add(:a) }
    it "should include element" do
      set.should include(:a)
    end

    it "object should have exponent 1 " do
      set[:a].should == 1
    end
  end

  describe "when #remove(object)" do
    let(:set) { ExponentSet.new.remove(:a) }
    it "should include element" do
      set.should include(:a)
    end

    it "object should have exponent -1 " do
      set[:a].should == -1
    end
  end

  describe "when #union(hash)" do
    let(:set_a) { ExponentSet[*%i{a a a b d}] }
    let(:set_b) { ExponentSet[*%i{a b b b}] }
    it "should contain all elements" do
      set_a.union(set_b).should == ExponentSet[*%i{a a a a b b b b d}]
    end
  end

  describe "when #subtract(hash)" do
    let(:set_a) { ExponentSet[*%i{a a a b c d}] }
    let(:set_b) { ExponentSet[*%i{a b b b c}] }
    it "should contain all elements" do
      set_a.subtract(set_b).should == ExponentSet.new({:a => 2, :b => -2, :d => 1})
    end
  end

  describe "when #intersect(hash)" do
    let(:set_a) { ExponentSet[*%i{a a a b c d}] }
    let(:set_b) { ExponentSet[*%i{a b b b c}] }
    it "should contain all elements" do
      set_a.intersect(set_b).should == ExponentSet[*%i{a b c}]
    end
  end

  describe "when #raise" do
    let(:set_a) { ExponentSet[:a, :a, :b].raise(2) }
    it "should contain all elements" do
      set_a.should == ExponentSet[*%i{a a a a b b}]
    end
  end

  describe "#compactable?" do
    it "should return true if it contain another exponentsset as key" do
      a = ExponentSet.new({:a => 3, :b => 2, ExponentSet.new({:c => 1}) => 1})
      a.compactable?.should be_true
    end
    it "should return false unless it contain another exponentsset as key" do
      a = ExponentSet.new({:a => 3, :b => 2, :c => 1})
      a.compactable?.should be_false
    end
  end

  describe "#compact" do
    it "should merge inner exponentset to self" do
      a = ExponentSet.new({:a => 3, :b => 2, ExponentSet.new({:b => 2, :c => 1}) => 1})
      a.compact.should == ExponentSet.new({:a => 3, :b => 4, :c => 1})
    end
    it "should raise inner exponentset to exponent" do
      a = ExponentSet.new({:a => 3, :b => 2, ExponentSet.new({:b => 2, :c => 1}) => 2})
      a.compact.should == ExponentSet.new({:a => 3, :b => 6, :c => 2})
    end
  end

  describe "when #compare_with" do
    it "must return nil unless equal elements" do
      a = ExponentSet.new({:a => 2, :b => 3})
      b = ExponentSet.new({:a => 2, :c => 3})
      a.compare_with(b) { |a_exp, b_exp| a_exp > b_exp }.should == nil
    end
    it "must return false unless true for all elements" do
      a = ExponentSet.new({:a => 2, :b => 3})
      b = ExponentSet.new({:a => 2, :b => 3})
      a.compare_with(b) { |a_exp, b_exp| a_exp > b_exp }.should == false
    end
    it "must return true if true for all elements" do
      a = ExponentSet.new({:a => 4, :b => 4})
      b = ExponentSet.new({:a => 2, :b => 3})
      a.compare_with(b) { |a_exp, b_exp| a_exp > b_exp }.should == true
    end
  end

  describe "#>(other)" do
    it "must be true if all elements of a are larger than all elements of b" do
      a = ExponentSet.new({:a => 4, :b => 4})
      b = ExponentSet.new({:a => 2, :b => 3})
      (a > b).should be_true
      a.proper_superset?(b).should be_true
    end
    it "must be false if not all elements of a are larger than all elements of b" do
      a = ExponentSet.new({:a => 4, :b => 3})
      b = ExponentSet.new({:a => 2, :b => 3})
      (a > b).should be_false
      a.proper_superset?(b).should be_false
    end
  end
  describe "#>=(other)" do
    it "must be true if all elements of a are larger than or equal all elements of b" do
      a = ExponentSet.new({:a => 4, :b => 4, :c => 2})
      b = ExponentSet.new({:a => 2, :b => 3, :c => 2})
      (a >= b).should be_true
      a.superset?(b).should be_true
    end
    it "must be false if not all elements of a are larger than all elements of b" do
      a = ExponentSet.new({:a => 4, :b => 4, :c => 2})
      b = ExponentSet.new({:a => 2, :b => 3, :c => 3})
      (a >= b).should be_false
      a.superset?(b).should be_false
    end
  end

  describe "#==(other)" do
    it "must be true if all elements of a are equal all elements of b" do
      a = ExponentSet.new({:a => 4, :b => 4, :c => 2})
      b = ExponentSet.new({:a => 4, :b => 4, :c => 2})
      (a == b).should be_true
    end
    it "must be false if not all elements of a are equal all elements of b" do
      a = ExponentSet.new({:a => 4, :b => 4, :c => 2})
      b = ExponentSet.new({:a => 4, :c => 2, :b => 3})
      (a == b).should be_false
    end
  end

  describe "#<=(other)" do
    it "must be true if all elements of a are less than or equal all elements of b" do
      a = ExponentSet.new({:a => 4, :b => 3, :c => 2})
      b = ExponentSet.new({:a => 4, :b => 4, :c => 2})
      (a <= b).should be_true
      a.subset?(b).should be_true
    end
    it "must be false if not all elements of a are less than or equal all elements of b" do
      a = ExponentSet.new({:a => 4, :b => 4, :c => 2})
      b = ExponentSet.new({:a => 4, :c => 2, :b => 3})
      (a <= b).should be_false
      a.subset?(b).should be_false
    end
  end

  describe "#<(other)" do
    it "must be true if all elements of a are less than all elements of b" do
      a = ExponentSet.new({:a => 3, :b => 3, :c => 1})
      b = ExponentSet.new({:a => 4, :b => 4, :c => 2})
      (a < b).should be_true
      a.proper_subset?(b).should be_true
    end
    it "must be false if not all elements of a are less than or equal all elements of b" do
      a = ExponentSet.new({:a => 3, :b => 3, :c => 1})
      b = ExponentSet.new({:a => 3, :c => 1, :b => 3})
      (a <= b).should be_false
      a.proper_subset?(b).should be_false
    end
  end
end