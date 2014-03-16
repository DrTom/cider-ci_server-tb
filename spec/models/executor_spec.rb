require 'spec_helper'

describe Executor do

  it "can be created" do
    expect{FactoryGirl.create :executor}.not_to raise_error
  end

  describe "is associated with an definition" do

    before :each do
      @repository = FactoryGirl.create :repository
      @specification = FactoryGirl.create :specification
      @definition = FactoryGirl.create :definition, repository: @repository, specification: @specification
      @executor = FactoryGirl.create :executor
    end

    # TODO 

  end

end
