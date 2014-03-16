require 'spec_helper'

describe Definition do
  before :each do
    @specification = FactoryGirl.create :specification
  end
  it "should be creatable" do
    expect{FactoryGirl.create :definition, specification: @specification}.not_to raise_error
  end
end
