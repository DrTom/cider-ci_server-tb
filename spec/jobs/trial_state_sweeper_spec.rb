require 'spec_helper'
require 'spec_helper_no_tx'

describe TrialStateSweeper do

  before :all do

    @repository = FactoryGirl.create :repository
    @commit = FactoryGirl.create :commit
    @branch = FactoryGirl.create :branch, repository: @repository, current_commit: @commit
    @specification = FactoryGirl.create :specification
    @execution = FactoryGirl.create :execution, 
      tree_id: @commit.tree_id, 
      specification: @specification
    @execution.create_tasks_and_trials

  end

  before :each do
    Trial.delete_all
    Task.first.check_and_retry!
    raise "precondition not met" if Trial.count != 1
    @trial = Trial.first
  end

  context "trial in not finished timeout" do
    before :each do
      Trial.connection.execute %[
        UPDATE trials 
          SET state = 'pending', 
              created_at =  (now() - interval '#{TimeoutSettings.find.trial_end_state_timeout_minutes} Minutes' - interval ' 1 Minutes')
          WHERE id = '#{@trial.id}' ]
      @trial.reload
    end
    it "is contained in the not_finished_timeout"  do
      expect(Trial.in_not_finished_timeout).to include @trial
    end
    context "sweeping" do
      before :each do
        TrialStateSweeper.new.run
      end
      it "sets the state to failed" do
        expect(@trial.reload.state).to be== 'failed'
      end
      it "doesn't create a new trial" do
        expect(Trial.all.count).to be== 1
      end
    end
  end

  context "trial in dispatch timeout" do
    before :each do
      Trial.connection.execute %[
        UPDATE trials 
          SET state = 'pending', 
              created_at =  (now() - interval '#{TimeoutSettings.find.trial_dispatch_timeout_minutes} Minutes' - interval ' 1 Minutes')
          WHERE id = '#{@trial.id}' ]
          @trial.reload
    end
    it "is contained in the dispatch timeout"  do
      expect(Trial.in_dispatch_timeout).to include @trial
    end
    context "sweeping" do
      before :each do
        TrialStateSweeper.new.run
      end
      it "sets the state to failed" do
        expect(@trial.reload.state).to be== 'failed'
      end
      it "doesn't create a new trial" do
        expect(Trial.all.count).to be== 1
      end
    end
  end

  context "trial in execution timeout" do
    before :each do
      Trial.connection.execute %[
        UPDATE trials 
          SET state = 'executing', 
              updated_at =  (now() - interval '#{TimeoutSettings.find.trial_execution_timeout_minutes} Minutes' - interval ' 1 Minutes')
          WHERE id = '#{@trial.id}' ]
          @trial.reload
    end
    it "is contained in the execution timeout"  do
      expect(Trial.in_execution_timeout).to include @trial
    end
    context "sweeping" do
      before :each do
        TrialStateSweeper.new.run
      end
      it "sets the state to failed" do
        expect(@trial.reload.state).to be== 'failed'
      end
      it "does create a new trial" do
        expect(Trial.all.count).to be== 2
      end
    end
  end

end
