require 'spec_helper'

describe Specification do

  it "is creatable" do
    expect{FactoryGirl.create :specification}.not_to raise_error
  end


  describe "data created by the factory" do

    before :each do
      @specification = FactoryGirl.create :specification
    end

  end

  describe "immutability of the data" do

    before :each do
      @specification = FactoryGirl.create :specification
    end

    it "is protected on update" do
      expect{@specification.update_attributes! data: {tasks:[{command: "ls"}]}}.to raise_error
    end

  end

end
