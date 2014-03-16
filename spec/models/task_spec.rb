require 'spec_helper'

describe Task do

  before :all do
    @repository = FactoryGirl.create :repository
    @commit = FactoryGirl.create :commit
    @branch = FactoryGirl.create :branch, repository: @repository, current_commit: @commit
    @specification = FactoryGirl.create :specification
    @execution = FactoryGirl.create :execution, 
      tree_id: @commit.tree_id, 
      specification: @specification
    @executor = FactoryGirl.create :executor

  end

  it "can be created manually" do
    expect do
      Task.create! \
        execution: @execution,
        traits: ["blah"]
    end.not_to raise_error
  end

  it "is created via create_tasks of the execution" do
    expect(@execution.tasks.count).to be == 0
    expect{@execution.create_tasks_and_trials }.not_to raise_error
    expect(@execution.tasks.count).to be > 0
  end

end
