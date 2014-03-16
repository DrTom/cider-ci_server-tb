require 'spec_helper'
require 'spec_helper_no_tx'

# TODO the sleep is a bad hack, implement wait_until ...

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

  describe "updating the state of a trial" do

    before :each do
      Task.delete_all
      @execution.create_tasks_and_trials
      Trial.delete_all # avoid callbacks
      @task = @execution.tasks.first 
      @trial1 = Trial.create! executor: @executor, task: @task
      @trial2 = Trial.create! executor: @executor, task: @task
      @trial3 = Trial.create! executor: @executor, task: @task
    end


    context "of one to dispatching" do
      before :each do
        @trial1.update_attributes! state: 'dispatching'
      end
      it "sets the state to executing" do
        sleep 0.1
        expect(@task.reload.state).to be == 'executing'
      end
    end

    context "of all to failed" do
      before :each do
        @trial1.update_attributes! state: 'failed'
        @trial2.update_attributes! state: 'failed'
        @trial3.update_attributes! state: 'failed'
      end
      it "sets the state to failed" do
        sleep 0.2
        expect(@task.reload.state).to be == 'failed'
      end
    end

    context "at least one to success" do
      before :each do
        @trial1.update_attributes! state: 'success'
        @trial2.update_attributes! state: 'failed'
      end
      it "sets the state to success" do
        sleep 0.1
        expect(@task.reload.state).to be == 'success'
      end
    end

  end

end
