require 'spec_helper'

describe Commit do

  before :each do
    @repository = FactoryGirl.create :repository
  end

  it "can be created" do
    expect{ FactoryGirl.create :commit}.not_to raise_error
  end


end

describe "Parent child relations of commits through arcs." do

  before :each do
    @repository = FactoryGirl.create :repository
    @tree_id = Digest::SHA1.hexdigest(rand.to_s)
    @commit1 = FactoryGirl.create :commit
  end

  describe  "An arc" do
    it "can be created by appending to children" do
      @commit1.children << (FactoryGirl.create :commit)
    end

    it "can be created by creating a child" do
      @commit1.children.create! id: Digest::SHA1.hexdigest(rand.to_s), tree_id: @tree_id
    end
  end

end
