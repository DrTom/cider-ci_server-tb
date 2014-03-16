require 'spec_helper'

describe Trial do

  before :each do
    @repository = FactoryGirl.create :repository
    @commit = FactoryGirl.create :commit
    @branch = FactoryGirl.create :branch, repository: @repository, current_commit: @commit
    @specification = FactoryGirl.create :specification
    @execution = FactoryGirl.create :execution, 
      tree_id: @commit.tree_id, 
      specification: @specification
    @execution.create_tasks_and_trials
    @task = @execution.tasks.first 
    @executor = FactoryGirl.create :executor
    Trial.destroy_all
  end

  it "should be creatable" do
    expect{ FactoryGirl.create :trial, task: @task}.not_to raise_error
  end

  it "can be associated with an executor " do
    expect{ FactoryGirl.create :trial, task: @task, executor: @executor}.not_to raise_error
  end



end
