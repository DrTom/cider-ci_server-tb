require 'spec_helper'
require 'spec_helper_no_tx'

describe AttachmentsSweeper do

  before :all do
    @repository = FactoryGirl.create :repository
    @commit = FactoryGirl.create :commit
    @branch = FactoryGirl.create :branch, repository: @repository, current_commit: @commit
    @specification = FactoryGirl.create :specification
    @execution = FactoryGirl.create :execution, 
      tree_id: @commit.tree_id, 
      specification: @specification
    @execution.create_tasks_and_trials
    @task = @execution.tasks.first 
    Trial.delete_all
    @task.check_and_retry!
    raise "precondition not met" if Trial.count != 1
    @trial = @task.trials.first
  end

  context "execatly one existing attachment " do

    before :each do 
      @attachment = FactoryGirl.create :attachment, trial: @trial
      raise if Attachment.all.count != 1
    end

    context "which is out of retention time" do
      before :each do
        Attachment.connection.execute %[
        UPDATE attachments 
          SET created_at = (now() - interval '#{TimeoutSettings.find.attachment_retention_time_hours} Hours' - interval '1 Hours')  
          WHERE trial_id = '#{@trial.id}' ]
          @attachment.reload
      end

      context "sweeping the attachments" do
        before :each do
          AttachmentsSweeper.new.run
        end

        it "deletes the one attachment" do
          expect(Attachment.count).to be== 0
        end

      end
    end
  end
end
