require "spec_helper"

describe DFS do

  context "identity dfs " do

    before :each do
      @idf1 = lambda{|s| s}
      @idf2 = lambda{|k,v| [k,v] }
      @idf_dfs = DFS.new(@idf1,@idf2)
    end
    
    it "has the correct identity context" do
      expect(@idf1.call(:x)).to be == :x
      expect(@idf2.call(:x,:y)).to be == [:x,:y]
    end

    it "has a traverse method" do
      expect(@idf_dfs).to respond_to :traverse
    end

    describe "invoking DFS on some singular value" do
      it "dosn't throw" do
        expect{@idf_dfs.traverse(5)}.not_to raise_error
      end
      it "returns that value" do
        expect(@idf_dfs.traverse(5)).to be == 5
      end
    end

    context "invoking idf_dfs on a very simple hash "do
      it "returns the hash" do
        expect(@idf_dfs.traverse({x: 5})).to be == {x: 5}
      end
    end

    context "invoking DFS on some nested hash" do

      before :each do
        @h = {x: {y: 5, z: 42}}
      end
      it "returns the hash" do
        expect( @idf_dfs.traverse(@h)).to be == @h
      end
    end

    context "invoking traverse on a hash" do

      before :each do
        @h = {x: 7, body_file: "blah"}
      end

      it "doesn't throw an error" do
        expect{@idf_dfs.traverse(@h) }.not_to raise_error
      end

    end
  end
end

