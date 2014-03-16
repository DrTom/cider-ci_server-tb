module DataFactory
  class << self

    def reload! 
      load Rails.root.join(__FILE__)
    end


    def create_demo_repo

      ActiveRecord::Base.transaction do

        test_repo_path = Rails.root.join "tmp", "test_repo"
        `rm -rf #{test_repo_path}`
        System.execute_cmd! %Q[tar xf #{Rails.root.join "spec", "data", "test_repo.tar.gz"} -C #{Rails.root.join "tmp"}]

        @repository = Repository.find_or_create_by!(name: "PrototypeRepo", origin_uri: test_repo_path.to_s)
        @repository.initialize_git
        @repository.update_branches

        @executor = FactoryGirl.create :executor, name: "PrototypeExecutor", host: 'localhost', port: '8443'

        @rspec_specification = FactoryGirl.create :rspec_specification 

        @rspec_definition = Definition.find_or_create_by name: "Rspec",  \
          specification: @rspec_specification

        @show_env_definition = Definition.find_or_create_by name: "ShowEnv",  \
          specification: (FactoryGirl.create :show_env_specification)

        Definition.find_or_create_by(name: "ShowEnv with failing substitution",
           specification: Specification.find_or_create_by_data!(self.show_env_specification_with_failing_substitution))

        @branch = @repository.branches.first

        BranchUpdateTrigger.create branch_id: @branch.id, definition_id: @show_env_definition.id

        tree_ids = @branch.current_commit.with_ancestors.map(&:tree_id).uniq

        (0..3).each do |i|
          tree = Tree.find tree_ids[i]
          commit = tree.commits.first
          execution = Execution.create! \
            specification: @rspec_specification,
            definition_name: @rspec_definition.name,
            tree: tree
          execution.create_tasks_and_trials
          #Trial.all.map(&:create_script_executions)
          execution.tasks.each do |task|
            task.trials.each{|t| t.update_attributes! state: Constants::EXECUTION_STATES[i], executor: @executor}
          end
        end
      end

    end

    def rspec_specification_data 
      @cached_rspec_specification ||= YAML.load_file(Rails.root.join("spec","data","rspec_specification.yml"))
    end

    def show_env_specification
      @cached_show_env_specification ||= YAML.load_file(Rails.root.join("spec","data","show_env_specification.yml"))
    end

    def rspec_specification_with_tasks_in_repo
      @cached_rspec_specification_with_tasks_in_repo ||= 
        YAML.load_file(Rails.root.join("spec","data","rspec_specification_with_tasks_in_repo.yml"))
    end

    def show_env_specification_with_failing_substitution
        YAML.load_file(Rails.root.join("spec","data","show_env_specification_with_failing_substitution.yml"))
    end


  end
end
