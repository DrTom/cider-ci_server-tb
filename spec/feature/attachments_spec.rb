require 'spec_helper'
require 'spec_capybara_conf'
require 'spec_helper_no_tx'

describe "Up and downloading of attachments", type: :feature, js: true do

  before :all do
    repositories_path= Rails.root.join("tmp","repositories").to_s
    System.execute_cmd! "rm -rf #{repositories_path}"
    System.execute_cmd! "mkdir -p #{repositories_path}"
    Settings.git.repositories_path= repositories_path

    ActiveRecord::Base.connection.tap do |connection|
      connection.tables.reject{|tn|tn=="schema_migrations"}.join(', ').tap do |tables|
        connection.execute " TRUNCATE TABLE #{tables} CASCADE; "
      end
    end

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
    @trial = @task.create_trial

    @bin_path= "spec/data/octets.bin"
    @attachment_name= "octets.bin"
    @output_path = "tmp/octets.bin"
  end

  it "can be uploaded; exists after; can be downloaded, and the content is equal to the previous uploaded content" do
    server = Capybara.current_session.server
    expect(@trial).to be_persisted
    expect{  System.execute_cmd! %Q< curl -s -X PUT -H "Content-Type: application/octet-stream"  \
         http://#{server.host}:#{server.port}/executors_api_v1/trials/#{@trial.id}/attachments/#{@attachment_name} \
         --data-binary @#{@bin_path} >
    }.not_to raise_error
    expect(@attachment = Attachment.find_by!(trial_id: @trial.id, path: @attachment_name)).to be
    curl_cmd = %[  
         curl -s  \
         "http://#{server.host}:#{server.port}/workspace/trials/#{@trial.id}/attachments/#{@attachment_name}" \
         -o #{@output_path} ]
    expect{ System.execute_cmd! curl_cmd }.not_to raise_error
    expect{ System.execute_cmd! "diff #{@bin_path} #{@output_path}" }.not_to raise_error # diff exits with /= 0 when not equal
  end

end

