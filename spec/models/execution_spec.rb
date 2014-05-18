require 'spec_helper'

describe Execution do

  context "given a repository, commit and specification with one task" do

    def test_repo_path
      Rails.root.join "tmp", "test_repo"
    end
  
    before :all do
      `rm -rf #{test_repo_path}`
      System.execute_cmd! "mkdir -p #{Rails.root.join 'tmp'}"
      System.execute_cmd! %Q[tar xf #{Rails.root.join "spec", "data", "test_repo.tar.gz"} -C #{Rails.root.join "tmp"}]
      ActiveRecord::Base.connection.tap do |connection|
        connection.tables.reject{|tn|tn=="schema_migrations"}.join(', ').tap do |tables|
          connection.execute " TRUNCATE TABLE #{tables} CASCADE; "
        end
      end
      repositories_path= Rails.root.join("tmp","repositories").to_s
      System.execute_cmd! "rm -rf #{repositories_path}"
      System.execute_cmd! "mkdir -p #{repositories_path}"
      ServerSettings.find.update_attributes! repositories_path: repositories_path
      @repository = Repository.find_or_create_by name: "TestRepo", origin_uri: test_repo_path.to_s
      @repository.initialize_git
    end

    before :each do
      @branch = @repository.branches.find_by name: 'master'
      @commit = @branch.current_commit
      @specification = FactoryGirl.create :rspec_specification
      @definition = FactoryGirl.create :definition, specification: @specification
    end

    describe ", creation"  do
      it "it is possible to create an execution " do
        expect{FactoryGirl.create :execution, 
          tree_id: @commit.tree_id, 
          definition_name: @definition.name,
          specification: @specification
        }.not_to raise_error
      end
    end


    context ", given an execution " do

      before :each do
        @execution = FactoryGirl.create :execution, 
          tree_id: @commit.tree_id, 
          definition_name: @definition.name,
          specification: @specification
        raise "precodition violated" unless @execution or (not @exeuction.persisted?) 
      end

      describe "invoking create_tasks_and_trials " do


        it "doen't raise an error" do
          expect{@execution.create_tasks_and_trials}.not_to raise_error
        end

        it "creates the corresponding task" do
          expect(@execution.tasks.size).to be == 0
          expect{@execution.create_tasks_and_trials}.not_to raise_error 
          expect(@execution.tasks.reload.size).to be == 4
        end


        it "does creates a trial too" do
          expect{@execution.create_tasks_and_trials}.not_to raise_error 
          expect(@execution.tasks.first.trials.count).to be == 1
        end

      end

      describe "updating the state of tasks" do

        before :each do
          @execution.create_tasks_and_trials
          @task1 = @execution.tasks.order(:name)[0] 
          @task2 = @execution.tasks.order(:name)[1]
          Task.where("ID not in (?)",[@task1.id,@task2.id]).destroy_all
          @task1.update_attributes! state: 'pending'
          @task2.update_attributes! state: 'pending'
          @execution.update_state!
        end

        describe "updating the state of one task to executing"  do
          before :each do
            @task1.update_attributes! state: 'executing'
          end
          it "sets the state of the execution to executing" do
            expect(@execution.reload.state).to be == 'executing'
          end
        end

        describe "updating the state of one task to failed and one to success" do
          before :each do
            @task1.update_attributes! state: 'failed'
            @task2.update_attributes! state: 'success'
          end
          it "sets the state to 'failed'" do
            expect(@execution.reload.state).to be == 'failed'
          end
        end


        describe "updating all task to success" do
          before :each do
            @task1.update_attributes! state: 'success'
            @task2.update_attributes! state: 'success'
          end
          it "sets the state to 'failed'" do
            expect(@execution.reload.state).to be == 'success'
          end
        end
      end
    end

    context "a specification with tasks defined in repo" do

      before :each do
        @rspec_specification_with_tasks_in_repo = Specification.find_or_create_by_data! DataFactory.rspec_specification_with_tasks_in_repo
      end

      it "it is possible to create an execution " do
        expect{FactoryGirl.create :execution, 
          tree_id: @commit.tree_id, 
          definition_name: @definition.name,
          specification: @rspec_specification_with_tasks_in_repo
        }.not_to raise_error
      end

      context "execution with rspec_specification_with_tasks_in_repo" do

        before :each do

          @execution_with_tasks_in_repo =
            FactoryGirl.create :execution, 
            tree_id: @commit.tree_id, 
            definition_name: @definition.name,
            specification: @rspec_specification_with_tasks_in_repo


          @fully_externalize_specification= Specification.find_or_create_by_data! \
            YAML.load %{--- 'substitute_with_path: spec/full_specification.yml'}

          @execution_with_nested_substitution=
            FactoryGirl.create :execution, 
            tree_id: @commit.tree_id, 
            definition_name: @definition.name,
            specification: @fully_externalize_specification
        end

        describe "substituted_specification_data" do

          it "contains the tasks, where as the unsubstituted doesn't" do
            expect{ 
              @substituted_specification_data = @execution_with_tasks_in_repo.substitute_specification_data
            }.not_to raise_error
            expect(@execution_with_tasks_in_repo.specification.data["contexts"][0]["tasks"]).to be== nil
            expect(@substituted_specification_data["contexts"][0]["tasks"]).not_to be== nil
            expect(@substituted_specification_data["contexts"][0]["tasks"]).to be_a Array
          end

        end

        describe "nested substituted_specification_data" do
          it "contains tasks, too" do
            expect{ 
              @substituted_specification_data = @execution_with_tasks_in_repo.substitute_specification_data
            }.not_to raise_error
            expect(@substituted_specification_data["contexts"][0]["tasks"]).to be_a Array
          end
        end

      end

    end
  end
end
