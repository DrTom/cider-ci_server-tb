require 'spec_helper'

describe ExecutorWithLoad do

  before :each do
    @repository = FactoryGirl.create :repository
    @commit = FactoryGirl.create :commit
    @branch = FactoryGirl.create :branch, repository: @repository, current_commit: @commit
    @specification = FactoryGirl.create :specification
    @execution = FactoryGirl.create :execution, 
      tree_id: @commit.tree_id, 
      specification: @specification
    @executor = FactoryGirl.create :executor, max_load: 5
    @execution.create_tasks_and_trials
    @task1 = @execution.tasks.order(:name)[0] 
    @task2 = @execution.tasks.order(:name)[1] 
    @task3 = @execution.tasks.order(:name)[2] 
    Trial.destroy_all
    Task.where("ID not in (?)",[@task1.id,@task2.id,@task3.id]).destroy_all

    @trial1 = FactoryGirl.create :trial, state: 'executing', executor: @executor, task: @task1
    @trial2 = FactoryGirl.create :trial, state: 'dispatching', executor: @executor, task: @task2
    @trial3 = FactoryGirl.create :trial, state: 'failed',executor: @executor, task: @task3
    @trial3 = FactoryGirl.create :trial, state: 'success',executor: @executor, task: @task3
  end

  it "finds the created execution" do
    expect{ ExecutorWithLoad.find @executor.id}.not_to raise_error
  end

  describe "computed loads " do
    before :each do
      @ewl = ExecutorWithLoad.find @executor.id
    end

    it "current_load is correct" do
      expect(@ewl.current_load).to be == 2
    end

    it "relative_load is correct" do
      expect(@ewl.relative_load).to be == 2.0/5.0
    end

  end

end
